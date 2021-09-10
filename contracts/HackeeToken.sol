// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract HackeeToken is ERC20 {
    address private owner;
    mapping(address => Hackee) public hackees;
    uint8 public jackpot;
    uint8 private luckyNumber;

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function!");
        _;
    }

    modifier onlyHackee() {
        require(hackees[msg.sender].tasks[0] == true, "You're not a hackee yet!");
        _;
    }

    modifier task(uint8 id) {
        require(
            hackees[msg.sender].tasks[id] == false,
            "You've already completed this task!"
        );
        _;
    }

    constructor() ERC20("Hackee", "HACKEE") {
        init();
    }

    function init() public {
        owner = msg.sender;
        jackpot = 1;
    }

    function addHackee(address addr, string memory name)
        public
        payable
        onlyOwner
        task(0)
    {
        hackees[addr].secret = uint8(block.timestamp % 255);
        hackees[addr].name = name;
        _mint(addr, 1);
        _setTaskDone(0);
    }

    function claimAirdrop(uint8 secret) public onlyHackee task(1) {
        require(hackees[msg.sender].secret == secret, "Airdrop authentication failed!");
        _mint(msg.sender, 3);
        _setTaskDone(1);
    }

    function playLottery() public onlyHackee task(2) {
      _burn(msg.sender, 1);

      if(hackees[msg.sender].secret == luckyNumber){
        _setTaskDone(2);
        _mint(msg.sender, jackpot);
      }
    }

    function setLuckyNumber(uint8 newLuckyNumber) public onlyOwner {
        luckyNumber = newLuckyNumber;
    }

    function increaseJackpot() public onlyOwner {
        unchecked {
            if (jackpot != 10) {
                jackpot += 1;
            }
        }
    }

    function decreaseJackpot() public onlyOwner {
        unchecked {
            jackpot -= 1;
        }
    }
    
    function getResults(address addr) external view returns (bool[3] memory tasks, uint balance){
        return (hackees[addr].tasks, balanceOf(addr));
    }

    function _setTaskDone(uint8 _id) private {
        hackees[msg.sender].tasks[_id] = true;
        increaseJackpot();
    }

    struct Hackee {
        string name;
        uint8 secret;
        bool[3] tasks;
    }
}
