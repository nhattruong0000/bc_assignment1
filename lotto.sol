pragma solidity ^0.4.20;


contract VirtLotto {
    address public owner;
    uint256 public maximumPlayer;
    uint256 public playerCount;
    uint256 public totalPick = 0;
    uint256 public betPrice; // 0.1 Ether
    uint256 public totalBet = 0;
    uint256 public constant MAX_NUMBER_OF_PLAYER = 3;
    uint256 public winNumber;
    // uint256 public constant RANGE = 3;
    address[] public playerList;

    struct Player {
        uint256[] pickNumbers;
        address playerAddress;
        bytes32 playerName;
        uint256 totalBetAmount;
        uint256 winningAmount;
    }

    mapping (uint=>Player) public playerInfos;
    // mapping (uint=>PlayerInfos
    
    function VirtLotto(uint256 bet) public {
        if (bet < betPrice) bet = betPrice;
        // maximumPlayer = maxPlayer;
        betPrice = bet;
        owner = msg.sender;
    }

    function pickNumber(bytes32 playerName, uint256 pickNumber) public payable {
        require(msg.value == betPrice);
        uint playerId = checkPlayerExists(msg.sender);
        if (playerId > 0) {
            if (playerInfos[playerId].pickNumbers.length < 4) {
                playerInfos[playerId].playerName = playerName;
                playerInfos[playerId].pickNumbers.push(pickNumber);
                playerInfos[playerId].playerAddress = msg.sender;
                playerInfos[playerId].totalBetAmount += msg.value;
                totalPick++;
                totalBet += msg.value;
            }
        } else {
            playerCount++;
            playerInfos[playerCount].playerName = playerName;
            playerInfos[playerCount].pickNumbers.push(pickNumber);
            playerInfos[playerCount].playerAddress = msg.sender;
            playerInfos[playerCount].totalBetAmount = msg.value;
            totalBet += msg.value;
            totalPick++;
            playerList.push(msg.sender);
        }
        if (playerCount >= MAX_NUMBER_OF_PLAYER) {
            generateWinner();
        }
    }

    function checkPlayerExists(address player) public returns (uint) {
        for (uint256 i = 1; i <= playerCount; i++) {
            if (playerInfos[i].playerAddress == player) {
                return i;
            }
        }
        return 0;
    }

    function generateWinner() public {
        winNumber = uint256(uint256(keccak256(block.timestamp, block.difficulty))%10);
        distributePrize(winNumber);
    }

    function distributePrize(uint256 winningNumber) public {
        address[] memory winners;
        uint[] memory winningIds;
        uint256 count = 0;
        for (uint256 i = 1; i <= playerCount; i++) {
            address playerAddress = playerInfos[i].playerAddress;
            uint256[] numbers = playerInfos[i].pickNumbers;
            for (uint256 y = 0; y < numbers.length; y++) {
                if (numbers[y] == winningNumber) {
                    winners[count] = playerAddress;
                    winningIds[count] = i;
                    count++;
                }
            }
        }

        uint256 winnerAmount = totalBet / count;

        for (uint256 j = 0; j < count; j++) {
            playerInfos[winningIds[j]].winningAmount = winnerAmount;
            if (winners[j] != address(0)) {
                winners[j].transfer(winnerAmount);
            }
        }
    }
    
    function playerList() public payable returns (uint256[3][4], address[], bytes32[], uint256[], uint256[]) {
        uint256[3][4] memory numberSelected;
        address[] memory playerAddressArray = new address[](playerCount);
        bytes32[] memory playerNames = new bytes32[](playerCount);
        uint256[] memory playerBetAmount = new uint256[](playerCount);
        uint256[] memory playerWinningAmount = new uint256[](playerCount);

        for (uint i = 0; i < playerCount; i++) {
            for (uint x = 0; x < playerInfos[i+1].pickNumbers.length; x++) {
                numberSelected[i][x] = playerInfos[i+1].pickNumbers[x];
            }
            playerAddressArray[i] = playerInfos[i+1].playerAddress;
            playerNames[i] = playerInfos[i+1].playerName;
            playerBetAmount[i] = playerInfos[i+1].totalBetAmount;
            playerWinningAmount[i] = playerInfos[i+1].winningAmount;
        }

        return (numberSelected, playerAddressArray, playerNames, playerBetAmount, playerWinningAmount);
    }

    function kill() public { 
        if (msg.sender == owner) {
            selfdestruct(owner); 
        }
    }
}