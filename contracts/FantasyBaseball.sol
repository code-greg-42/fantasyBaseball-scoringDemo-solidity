// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

contract FantasyBaseball {
    address owner;
    string leaguePw;
    uint256 public prize;
    uint256 public startTime;
    uint256 public endTime;
    bytes32 public leagueRoster;
    bool public leagueHasStarted;

    struct Team {
        string teamName;
        string username;
        address ethAddress;
        uint256[] roster;
    }

    struct User {
        string username;
        uint256 teamId;
        bytes32 pw;
        bool active;
    }

    struct Trade {
        uint256 tradeId;
        uint256 teamId_1;
        uint256 teamId_2;
        uint256 playerId_11;
        uint256 playerId_12;
        uint256 playerId_21;
        uint256 playerId_22;
        bool isGamble;
        bool isApproved;
        bool gamble_team_1;
        bool gamble_team_2;
    }

    event NewTeam(string _teamName, string _username, uint256 _teamId);
    event PickSubmitted(
        string _teamName,
        string _username,
        address _ethAddress,
        uint256 _teamId,
        uint256 _playerId
    );
    event NewTradeProposal(
        uint256 _tradeId,
        uint256 _teamId_1,
        uint256 _teamId_2,
        uint256 _playerId_11,
        uint256 _playerId_12,
        uint256 _playerId_21,
        uint256 _playerId_22,
        uint256 _proposal_timestamp,
        bool _isGamble
    );
    event TradeAccepted(
        uint256 _tradeId,
        uint256 _teamId_1,
        uint256 _teamId_2,
        uint256 _playerId_11,
        uint256 _playerId_12,
        uint256 _playerId_21,
        uint256 _playerId_22,
        uint256 _accept_timestamp,
        bool _isGamble,
        bool _gamble_team_1,
        bool _gamble_team_2
    );

    mapping(uint256 => Team) teams;
    mapping(string => User) private usernames;
    mapping(uint256 => Trade) trades;
    uint256 public totalTeams;
    uint256 public totalTrades;

    constructor(string memory _leaguePw) payable {
        owner = msg.sender;
        leaguePw = _leaguePw;
        prize = msg.value;
        startTime = block.timestamp;
        endTime = block.timestamp + 6 weeks;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    receive() external payable {}

    function join(
        string memory _leaguePw,
        string memory _teamName,
        string memory _username,
        address _ethAddress,
        bytes32 _pw,
        uint256[] memory _roster
    ) public onlyOwner {
        require(
            keccak256(abi.encodePacked(_leaguePw)) ==
                keccak256(abi.encodePacked(leaguePw)),
            "wrong league password!"
        );
        require(!usernames[_username].active, "this account already exists");
        uint256 _teamId = totalTeams;
        Team memory team = Team(_teamName, _username, _ethAddress, _roster);
        User memory user = User(
            _username,
            _teamId,
            keccak256(abi.encodePacked(_pw)),
            true
        );
        teams[_teamId] = team;
        usernames[_username] = user;
        emit NewTeam(_teamName, _username, _teamId);
        totalTeams++;
    }

    function login(string memory _username, bytes32 _pw)
        public
        view
        onlyOwner
        returns (uint256 _teamId)
    {
        require(usernames[_username].active);
        require(usernames[_username].pw == keccak256(abi.encodePacked(_pw)));
        _teamId = usernames[_username].teamId;
    }

    function submitPick(string memory _username, uint256 _playerId)
        public
        onlyOwner
    {
        require(usernames[_username].active);
        uint256 _teamId = usernames[_username].teamId;
        string memory _teamName = teams[_teamId].teamName;
        address _ethAddress = teams[_teamId].ethAddress;
        teams[_teamId].roster.push(_playerId);
        emit PickSubmitted(
            _teamName,
            _username,
            _ethAddress,
            _teamId,
            _playerId
        );
    }

    function getRoster(string memory _username)
        public
        view
        onlyOwner
        returns (uint256[] memory _roster)
    {
        uint256 _teamId = usernames[_username].teamId;
        _roster = teams[_teamId].roster;
    }

    function proposeTrade(
        uint256 _teamId_1,
        uint256 _teamId_2,
        uint256 _playerId_11,
        uint256 _playerId_12,
        uint256 _playerId_21,
        uint256 _playerId_22,
        bool _isGamble
    ) public onlyOwner {
        uint256 _tradeId = totalTrades;
        Trade memory trade = Trade(
            _tradeId,
            _teamId_1,
            _teamId_2,
            _playerId_11,
            _playerId_12,
            _playerId_21,
            _playerId_22,
            _isGamble,
            false,
            false,
            false
        );
        trades[_tradeId] = trade;
        emit NewTradeProposal(
            _tradeId,
            _teamId_1,
            _teamId_2,
            _playerId_11,
            _playerId_12,
            _playerId_21,
            _playerId_22,
            block.timestamp,
            _isGamble
        );
        totalTrades++;
    }

    function acceptTrade(
        uint256 _tradeId,
        bool gamble_team1_index,
        bool gamble_team2_index
    ) public onlyOwner {
        require(
            !trades[_tradeId].isApproved,
            "trade has already been approved"
        );
        emit TradeAccepted(
            _tradeId,
            trades[_tradeId].teamId_1,
            trades[_tradeId].teamId_2,
            trades[_tradeId].playerId_11,
            trades[_tradeId].playerId_12,
            trades[_tradeId].playerId_21,
            trades[_tradeId].playerId_22,
            block.timestamp,
            trades[_tradeId].isGamble,
            gamble_team1_index,
            gamble_team2_index
        );
        trades[_tradeId].isApproved = true;
    }

    function startLeague(bytes32 _cid) public onlyOwner {
        require(block.timestamp > startTime, "not yet!");
        leagueHasStarted = true;
        leagueRoster = _cid;
    }

    function payWinner(uint256 _teamId) public onlyOwner {
        require(block.timestamp > endTime);
        payable(teams[_teamId].ethAddress).transfer(address(this).balance);
    }
}
