// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@chainlink/contracts/src/v0.8/VRFConsumerBase.sol";

contract baseCasino {

    //platform getter functions
    address public teamWallet;
    uint256 public totalPlayers;
    uint256 public transactionVolume;
    uint256 public totalFees;

    //lottery params
    uint256 public ticketPrice;
    uint256 public currentWeek = 1;
    uint256 public superBowlPool;
    uint256 public rolloverPool;
    address public owner;

    // Prize Distribution Percentages
    uint256 public constant WINNER_PERCENTAGE = 90;
    uint256 public constant PLATFORM_PERCENTAGE = 5;
    uint256 public constant SUPER_BOWL_PERCENTAGE = 5;
    uint256 public constant ROLLOVER_PERCENTAGE = 10;

    // Chainlink VRF Parameters
    bytes32 internal keyHash;
    uint256 internal fee;

    struct Ticket {
        address owner;
        uint256 number;
    }

    struct DrawInfo {
        Ticket[] tickets;
        address winner;
        mapping (uint256 => bool) takenNumbers;
        uint256 totalContributions;
        uint256 startTime;
        uint256 endTime;
        uint256 totalPlayers;
    }

    mapping(uint256 => DrawInfo)  weeklyDraws; // Tracks each weekly draw by week number
    mapping(address => uint256) public xpPoints; // Tracks XP points for users
    mapping(uint256 => address[]) public superBowlWinners; // Super Bowl winners

    event TicketPurchased(address indexed buyer, uint256 indexed week, uint256 number);
    event WeeklyDrawResult(uint256 indexed week, uint256 winningNumber, address winner);
    event SuperBowlDrawResult(uint256 indexed superBowlRound, uint256[] winningNumbers, address[] winners);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the contract owner");
        _;
    }

    constructor(address _vrfCoordinator, address _linkToken, bytes32 _keyHash, uint256 _fee)
        VRFConsumerBase(_vrfCoordinator, _linkToken) {
        owner = msg.sender;
        keyHash = _keyHash;
        fee = _fee;
        weeklyDraws[currentWeek].startTime = block.timestamp; // Initialize start time for the first draw
    }

    function buyTicket(uint256 number) external payable {
        require(msg.value == ticketPrice, "Incorrect ticket price");
        require(!_numberAlreadyTaken(currentWeek, number), "Number already taken");

        DrawInfo storage draw = weeklyDraws[currentWeek];
        
        draw.tickets.push(Ticket({
            owner: msg.sender,
            number: number
        }));
        draw.takenNumbers[number] = true;
        draw.totalContribution += msg.value;

        xpPoints[msg.sender] += 10; // Award 10 XP points

        emit TicketPurchased(msg.sender, currentWeek, number);
    }



}
