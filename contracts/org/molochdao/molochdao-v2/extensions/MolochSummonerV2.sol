/// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

interface IMolochSummoner {
    function summonMoloch(
        address[] memory _summoner,
        address[] memory _approvedTokens,
        uint256 _periodDuration,
        uint256 _votingPeriodLength,
        uint256 _gracePeriodLength,
        uint256 _proposalDeposit,
        uint256 _dilutionBound,
        uint256 _processingReward,
        uint256[] memory _summonerShares
    ) external returns (address);
}

interface IMinionFactory {
    function summonMinion(address moloch, string memory details) external returns (address);
}

interface IRicardianLLC {
    function mintLLC(address to) external payable;
}

/// @notice Summon a Moloch DAO v2 (daohaus.club) with Minion and optional LLC formation maintained by LexDAO (ricardian.gitbook.io).
contract MolochSummonerV2 { 
    IMolochSummoner constant dhMolochSummoner = IMolochSummoner(0x38064F40B20347d58b326E767791A6f79cdEddCe);
    IMinionFactory constant dhMinionFactory = IMinionFactory(0x88207Daf515e0da1A32399b3f92D128B1BF45294);
    IRicardianLLC constant ricardianLLC = IRicardianLLC(0x43B644a01d87025c9046F12eE4cdeC7E04258eBf);
    
    event SummonMoloch(address indexed moloch, address indexed minion, bool mintLLC);
    
    function summonMoloch(
        address[] memory _summoner,
        address[] memory _approvedTokens,
        uint256 _periodDuration,
        uint256 _votingPeriodLength,
        uint256 _gracePeriodLength,
        uint256 _proposalDeposit,
        uint256 _dilutionBound,
        uint256 _processingReward,
        uint256[] memory _summonerShares,
        string memory details,
        bool mintLLC
    ) public payable returns (address moloch, address minion) {
        moloch = dhMolochSummoner.summonMoloch( // summon Moloch
            _summoner,
            _approvedTokens,
            _periodDuration,
            _votingPeriodLength,
            _gracePeriodLength,
            _proposalDeposit,
            _dilutionBound,
            _processingReward,
            _summonerShares);
        minion = dhMinionFactory.summonMinion(moloch, details); // summon Minion
        if (mintLLC) ricardianLLC.mintLLC{value: msg.value}(minion); // form LLC for DAO and deposit registration NFT into Minion - fwd any ether to Ricardian LLC mgmt
        emit SummonMoloch(moloch, minion, mintLLC);
    }
}
