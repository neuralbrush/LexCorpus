/// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.0;

interface IToken { // brief interface for erc20/721 txs
    function transfer(address to, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}

contract Escrow {
    address public ETH_TOKEN = address(0);
    uint256 public lockerCount;
    
    mapping(uint256 => Locker) public lockers;
    
    event DepositLocker(address sender, address receiver, address token, uint256 amount, uint256 registration);
    event ReleaseLocker(uint256 registration);
    
    struct Locker {  
        address sender;
        address receiver;
        address token;
        uint256 amount;
    }
    
    receive() payable external {}
    
    function depositLocker(address receiver, address token, uint256 amount) external payable {
        if (token == ETH_TOKEN) {
            (bool success, ) = address(this).call{value: amount}("");
            require(success, "withdraw failed");
        } else {
            IToken erc20 = IToken(token);
            erc20.transferFrom(msg.sender, address(this), amount);
        }
        
        lockerCount++;
        uint256 registration = lockerCount;

        lockers[registration] = Locker(msg.sender, receiver, token, amount);
        
        emit DepositLocker(msg.sender, receiver, token, amount, registration);
    }
    
    function depositLockerNFT(address receiver, address token, uint256 tokenId) external payable {
        IToken erc721 = IToken(token);
        erc721.transferFrom(msg.sender, address(this), tokenId);
        
        lockerCount++;
        uint256 registration = lockerCount;

        lockers[registration] = Locker(msg.sender, receiver, token, tokenId);
        
        emit DepositLocker(msg.sender, receiver, token, tokenId, registration);
    }
    
    function releaseLocker(uint256 registration) external {
        require(msg.sender == lockers[registration].sender);
        
        if (lockers[registration].token == ETH_TOKEN) {
            (bool success, ) = lockers[registration].receiver.call{value: lockers[registration].amount}("");
            require(success, "withdraw failed");
        } else {
            IToken erc20 = IToken(lockers[registration].token);
            erc20.transfer(lockers[registration].receiver, lockers[registration].amount);
        }
        
        emit ReleaseLocker(registration);
    }
    
    function releaseLockerNFT(uint256 registration) external {
        require(msg.sender == lockers[registration].sender);
        
        IToken erc721 = IToken(lockers[registration].token);
        erc721.transferFrom(address(this), lockers[registration].receiver, lockers[registration].amount);
        
        emit ReleaseLocker(registration);
    }
}
