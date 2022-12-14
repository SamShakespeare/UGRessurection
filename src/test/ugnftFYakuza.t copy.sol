// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.13;

import "ds-test/test.sol";

import "../UGNFT.sol";
import "../UGFYakuza.sol";
import "../UGRaid.sol";
 import "../UGgame.sol";
 import "../UGWeapons.sol";
 import "../Randomizer.sol";
 import "../UGArena.sol";
 import '../RaidEntry.sol';
// import "../interfaces/IUBlood.sol";
//import "../interfaces/IUGNFT2.sol";
import "../interfaces/IUNFT.sol";
// import "../interfaces/IUGame.sol";
 import "../UGForgeSmith.sol";
// import "../interfaces/IUGRaid.sol";

import "./console.sol";

interface IUGMigration {
    function migrateRingAmulet(uint256[] calldata tokenIds, bool isRing) external;
    function migrateFighters(uint256[] calldata v1TokenIds) external;
}

interface HEVM {
    function warp(uint256 time) external;

    function roll(uint256) external;

    function prank(address) external;

    function prank(address, address) external;

    function startPrank(address) external;

    function startPrank(address, address) external;

    function stopPrank() external;

    function deal(address, uint256) external;

    function expectRevert(bytes calldata) external;
    function expectRevert() external;

}

interface IUBlood {
    function mint(address to, uint256 amount) external;
    function burn(address from, uint256 amount) external;
    function addAdmin(address addr) external;
}


contract UGNFTsTest is DSTest {
    //user total balances bit indexes
  uint256 internal constant FIGHTER_INDEX  = 1;
  uint256 internal constant RING_INDEX  = 2;
  uint256 internal constant AMULET_INDEX  = 3;
  uint256 internal constant FORGE_INDEX  = 4;
  uint256 internal constant FIGHT_CLUB_INDEX  = 5;

    // Cheatcodes
    HEVM public hevm = HEVM(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    // Users
    address public owner;
    address public user1 = address(0x1337);
    address public user2 = address(0x1338);
    address public user3 = address(0x1339);
    address public user4 = address(0x1340);
    address public mockOwner = address (0xdeadbeef);

    // Deployments
    UGFYakuza public ugFYakuza;
    UGNFT public ugNFT;
     UGArena public ugArena;
     IUBlood public uBLOOD;
     UGgame public ugGame;
     UGRaid public ugRaid;
     Randomizer public randomizer;
     UGWeapons public ugWeapons;
     RaidEntry public raidEntry;
    // IUNFT public uNft;
    // Migrations public ugMigration;
    // IUGame public oldGameTest;
     UGForgeSmith public ugForgeSmith;


    uint bal;
    uint amt;
    uint8 lvl;

    function setUp() public {
      //   address oldGameTestnet = 0xE0BDf2e2EF2fda69B20dc54D224A64F99F640336;
         address bloodOwnerTestnet = 0x5b8F11C2c1E33f0857c12Da896bF7c86A8101023;//testnet blood owner
         address bloodContractTestnet = 0x649A53b481031ff57367F672e07d0A488ad421d9;//testnet blood addy
      //  // address ugMigrationContractTestnet = 0x110Bb92C476C6FDC55C1EA1203e54bB2833d2A8a;//testnet blood addy
      //   address unftOldMock_testnet = 0x8a169361770A0d74818e7129d1E2118207168B5e;//testnet old unft
      //   // address ugNFTTestContract = 0x4Fb487506cCCFC12B7E3AF29B68801039D83B4B2;
      //   address ugNFTTestContract = 0xDF2b74A1B2B0c8A715c8808D3a8b599Fa7bdA8DD;
      //   address ugRaidtestContract = 0xF7FD054793165525d85FBEAb9F290eCEf6B65cb8;
      //   address ugArenaTestContract = 0x6eDeA9530549B67B3eB063280CD61e7d41806791;
        string memory uri = "https://the-u.club/reveal/";
        string memory name = "FYakuza";
        string memory symbol = "UGFY";
        string memory name1 = "UGNfts";
        string memory symbol1 = "UGNFT";
        
        //Deploy Contracts
        randomizer = new Randomizer();
        ugFYakuza = new UGFYakuza(uri, name, symbol);
        ugNFT =  new UGNFT(uri, name1, symbol1);
         uBLOOD = IUBlood(bloodContractTestnet);//testnet blood addy
         ugArena = new UGArena(address(ugNFT), address(ugFYakuza), bloodContractTestnet, address(randomizer));
         ugWeapons = new UGWeapons();
         ugRaid = new UGRaid(address(ugNFT), address(ugFYakuza), bloodContractTestnet, address(ugArena), address(ugWeapons), address(randomizer), mockOwner, 20001);
      //   ugRaid = IUGRaid(ugRaidtestContract);
      //   //ugMigration = IUGMigration(ugMigrationContractTestnet);//testnet migration contract
      //   ugMigration = new Migrations(address(ugNFT),bloodContractTestnet, 0xb19A304598603bf3645fb6b06D27985581D44e5a, 0xe95d607EC03B6fC991FfBe86ad3841A951631c42, unftOldMock_testnet, address(ugArena), 0xE0BDf2e2EF2fda69B20dc54D224A64F99F640336 );//testnet migration contract
       
      //   uNft = IUNFT(unftOldMock_testnet);
      //   oldGameTest = IUGame(oldGameTestnet);

      raidEntry = new RaidEntry( address(ugFYakuza), bloodContractTestnet, address(ugArena), address(ugWeapons), address(ugRaid), address(bloodOwnerTestnet));

        //forgesmith
         ugForgeSmith = new UGForgeSmith(address(ugNFT), address(ugFYakuza), address(uBLOOD), address(ugWeapons), address(ugRaid), address(ugArena));
         ugGame = new UGgame(address(ugNFT),address(ugFYakuza),address(ugArena), address(ugRaid), bloodContractTestnet,  address(ugForgeSmith), mockOwner);
        
        
        ugArena.setPaused(false);
        ugArena.setGameContract(address(ugGame));
        //set Admins
        ugRaid.addAdmin(address(ugGame));
        ugArena.addAdmin(address(ugGame));
        ugArena.addAdmin(address(ugRaid));
        ugArena.addAdmin(address(ugForgeSmith));

        ugNFT.addAdmin(address(ugGame));
        ugNFT.addAdmin(address(ugRaid));
        //ugNFT.addAdmin(address(ugMigration));
        ugNFT.addAdmin(address(ugForgeSmith));
        ugNFT.addAdmin(address(ugArena));

        ugFYakuza.addAdmin(address(ugGame));
        ugFYakuza.addAdmin(address(ugRaid));
        //ugFYakuza.addAdmin(address(ugMigration));
        ugFYakuza.addAdmin(address(ugForgeSmith));
        ugFYakuza.addAdmin(address(ugArena));
        ugForgeSmith.addAdmin(address(ugGame));
        

        //turn on  minting
        ugGame.setAmuletMintActive(true);
        ugGame.setRingMintActive(true);
        ugGame.setForgeMintActive(true);
        ugGame.setFightClubMintActive(true);

        ugRaid.setDevWallet(mockOwner);
        ugRaid.setDevFightClubId(20001);
        ugRaid.addAdmin(address(raidEntry));
        ugWeapons.addAdmin(address(ugRaid));
        ugWeapons.addAdmin(address(ugForgeSmith));
        ugWeapons.addAdmin(address(raidEntry));
        ugWeapons.addAdmin(address(this));
        
        ugGame.setDevWallet(mockOwner);
        ugForgeSmith.setDevWallet(mockOwner);

        //phase switches
        ugRaid.setWeaponsRound(true);
        ugRaid.setYakuzaRound(true);
       // ugRaid.setSweatRound(true);
      
        //blood auth
        hevm.startPrank(bloodOwnerTestnet);
         uBLOOD.addAdmin(address(ugGame));
        uBLOOD.addAdmin(address(ugRaid));
        uBLOOD.addAdmin(address(raidEntry));
        uBLOOD.addAdmin(address(ugForgeSmith));
        uBLOOD.mint(user1, 60000000 ether);
        uBLOOD.mint(user2, 60000000 ether);
        uBLOOD.addAdmin(address(ugArena));
        hevm.stopPrank();
        
        ugFYakuza.addAdmin(address(this));
        
     
        //approvals
        hevm.startPrank(user1, user1);
        // ugFYakuza.setApprovalForAll(address(this), true);
        // ugNFT.setApprovalForAll(address(this), true);
     //   ugNFT.setApprovalForAll(address(ugForgeSmith), true);
     //   ugWeapons.setApprovalForAll(address(this), true);
        ugFYakuza.setApprovalForAll(address(ugArena), true);
        ugNFT.setApprovalForAll(address(ugArena), true);
        ugNFT.setApprovalForAll(address(ugForgeSmith), true);
        ugFYakuza.setApprovalForAll(address(ugRaid), true);
        ugNFT.setApprovalForAll(address(ugRaid), true);
      //  ugNFT.setApprovalForAll(address(ugRaid), true);
        
        hevm.stopPrank();

        hevm.startPrank(user2, user2);
         ugFYakuza.setApprovalForAll(address(ugArena), true);
        ugNFT.setApprovalForAll(address(ugArena), true);
        ugNFT.setApprovalForAll(address(ugForgeSmith), true);
        ugFYakuza.setApprovalForAll(address(ugRaid), true);
        ugNFT.setApprovalForAll(address(ugRaid), true);
       
        hevm.stopPrank();

        hevm.startPrank(user3, user3);
       
        hevm.stopPrank();

        hevm.startPrank(user4, user4);
       
        hevm.stopPrank();

       

                
        // bal = uBLOOD.balanceOf(user1);
        // console.log("blood bal user1", bal/1e18);
        //bal = uBLOOD.balanceOf(user2);
        //console.log("blood bal user2", bal/1e18);

        hevm.warp(1000);

        //mint fighters
        amt = 20;
        lvl= 15;

        uint256[] memory _fighterIds = new uint256[](11);
        for (uint i=2;i<=12;i++){
            _fighterIds[i-2] = i;
        }

          batchMintFighters(user1, lvl,amt, true,1);
          batchMintFighters(user1, lvl,amt, false,61);
          batchMintFighters(user2, lvl,amt, true,121);
         batchMintFighters(user2, lvl,amt, false,181);
     
    }

    function batchMintFighters(address user, uint8 _level, uint numFighters, bool _isFighter, uint16 startIndex) internal {
        //uint numFighters = 44;
        IUGFYakuza.FighterYakuza[] memory FY = new IUGFYakuza.FighterYakuza[](numFighters);
        uint256[] memory _ids = new uint256[](numFighters);
       // address[] memory user1Array = new address[](numFighters);
       // address[] memory user2Array = new address[](numFighters);

        for(uint32 i = 0; i < numFighters; i++){
            FY[i] = IUGFYakuza.FighterYakuza({
                isFighter: _isFighter,
                Gen: 0,
                rank: 5,
                courage: uint8((65 + i)%100),
                cunning: uint8((25 + i)%100),
                brutality: uint8((50 + i)%100),
                level: _level,
                scars: uint16((25 + 5*i)%250),
                imageId: uint16(i+startIndex),
                knuckles: uint8(((i +1)%5)*10),
                chains: uint8(((i +2)%5)*10),
                butterfly: uint8(((i +3)%5)*10),
                machete: uint8(((i+1)%5)*10),
                katana: uint8(((i +1)%5)*10),
                lastLevelUpgradeTime: 0,
                lastRankUpgradeTime: 0,
                lastRaidTime: 0
            });
            _ids[i] = FY[i].imageId;
          //  user1Array[i] = user1;
          //  user2Array[i] = user2;
        }

        ugFYakuza.batchMigrateFYakuza(user, _ids,FY );

    }

    function testMintBatchFighters() public {
      
     // uint256[] memory ids = createAmountsArray(50, 5000, 1, 1);
        // uint256[] memory retrievedIds = ugNFT2.getNftIDsForUser(user1, FIGHTER_INDEX);   
        // console.log("balance of Fighters user1", retrievedIds.length);
     uint256[] memory IdsUser = ugFYakuza.walletOfOwner(user1);

      // uint256 numfighters = ugFYakuza.getNumFightersForUser(user1);
      // console.log(numfighters);

     
    //   ugFYakuza.burn(user1, 16);
    //   IdsUser = ugFYakuza.walletOfOwner(user1);
    //   ugFYakuza.batchBurn(user1, createAmountsArray(10, 1, 1, 100),createAmountsArray(10, 1, 0, 1));
      
      // IdsUser = ugFYakuza.walletOfOwner(user1);
      // numfighters = ugFYakuza.balanceOf(user1);

      hevm.startPrank(user1, user1);
    //   ugFYakuza.safeBatchTransferFrom( user1, user2, createAmountsArray(4, 11, 1, 100),createAmountsArray(4, 1, 0, 1),"" );
    //   IdsUser = ugFYakuza.walletOfOwner(user1);
    //   numfighters = ugFYakuza.balanceOf(user1);

      // IdsUser = ugFYakuza.walletOfOwner(user2);
      // numfighters = ugFYakuza.balanceOf(user2);

    //   ugFYakuza.safeBatchTransferFrom( user1, user2, createAmountsArray(4, 16, 1, 100),createAmountsArray(4, 1, 0, 1),"" );
    //   IdsUser = ugFYakuza.walletOfOwner(user1);
    //   numfighters = ugFYakuza.balanceOf(user1);

    //   IdsUser = ugFYakuza.walletOfOwner(user2);
    //   numfighters = ugFYakuza.balanceOf(user2);

    //test stake    
        ugArena.stakeManyToArena( ugFYakuza.walletOfOwner(user1));
        IdsUser = ugArena.getStakedFighterIDsForUser(user1);
 //    IdsUser = ugArena.getStakedYakuzaIDsForUser(user1);
        ugGame.mintRing();
        ugGame.mintAmulet();
      ugArena.stakedByOwner(user1); 
      hevm.warp(2 days + 1);

      
      // console.log('ring',ugNFT.getNftIDsForUser(user1, 2)[0]);
      // console.log('amulet',ugNFT.getNftIDsForUser(user1, 3)[0]);

      ugArena.stakeRing(ugNFT.getNftIDsForUser(user1, 2)[0]);
      ugArena.stakeAmulet(ugNFT.getNftIDsForUser(user1, 3)[0]);
      
      hevm.stopPrank();

       hevm.startPrank(user2, user2);
    //   ugFYakuza.safeBatchTransferFrom( user2, user1, ugFYakuza.walletOfOwner(user2), createAmountsArray(numfighters, 1, 0, 1),"" );
    //   IdsUser = ugFYakuza.walletOfOwner(user1);
    //   numfighters = ugFYakuza.balanceOf(user1);
            ugGame.mintRing();
        ugGame.mintAmulet();
        hevm.warp(4 days + 2);
    //test stake    
        ugArena.stakeManyToArena( ugFYakuza.walletOfOwner(user2));
        IdsUser = ugArena.getStakedFighterIDsForUser(user2);
      IdsUser = ugArena.getStakedYakuzaIDsForUser(user2);

    // console.log('ring',ugNFT.getNftIDsForUser(user2, 2)[0]);
    //   console.log('amulet',ugNFT.getNftIDsForUser(user2, 3)[0]);

       ugArena.stakeRing(ugNFT.getNftIDsForUser(user2, 2)[0]);
      ugArena.stakeAmulet(ugNFT.getNftIDsForUser(user2, 3)[0]);
    //   IdsUser = ugFYakuza.walletOfOwner(user2);
    //   numfighters = ugFYakuza.balanceOf(user2);
      hevm.stopPrank();

      hevm.startPrank(user1, user1);

      

        // ugArena.stakedByOwner(user1);
        // IdsUser = ugArena.getStakedFighterIDsForUser(user1);
        // IdsUser = ugArena.getStakedFighterIDsForUser(user2);
        // //ugArena.getStakedYakuzaIDsForUser(user1);
        // IdsUser = ugFYakuza.walletOfOwner(address(ugArena));
        // IdsUser = ugFYakuza.walletOfOwner(user1);

        // ugArena.numUserStakedFighters(user1);
        // ugArena.numUserStakedFighters(user2);
        // ugArena.numUserStakedYakuza(user1);
        // ugArena.numUserStakedYakuza(user2);


        hevm.warp(9 days);   
      
        ugArena.claimManyFromArena(ugArena.getStakedFighterIDsForUser(user1), false);
        ugArena.claimManyFromArena(ugArena.getStakedYakuzaIDsForUser(user1), false);
   
    //    IdsUser = ugArena.getStakedFighterIDsForUser(user1);
    //    IdsUser = ugFYakuza.walletOfOwner(user1);
    hevm.stopPrank();

     hevm.startPrank(user2, user2);

      console.log('user2 blood bal before claim fighters',uBLOOD.balanceOf(user2));
        ugArena.claimManyFromArena(ugArena.getStakedFighterIDsForUser(user2), false);
        console.log('user2 blood bal after claim fighters',uBLOOD.balanceOf(user2));
        ugArena.claimManyFromArena(ugArena.getStakedYakuzaIDsForUser(user2), false);
        console.log('user2 blood bal after claim yakuza',uBLOOD.balanceOf(user2));
    //    IdsUser = ugArena.getStakedFighterIDsForUser(user2);
    //    IdsUser = ugFYakuza.walletOfOwner(user2);
    hevm.stopPrank();

    console.log('bpR',ugArena.getBloodPerRank());
    ugArena.totalRankStaked();


         hevm.startPrank(user2, user2);
   
        IdsUser = ugNFT.getNftIDsForUser(user2, 3);
    hevm.stopPrank();

     hevm.startPrank(user1, user1);
        ugGame.mintFightClubs(1);
        
        
        ugGame.mintForges(1);
        IdsUser = ugNFT.getNftIDsForUser(user1, 4);
        ugGame.levelUpForges(IdsUser, createAmountsArray(IdsUser.length, 1, 0 , 5));
        ugForgeSmith.stakeForges(IdsUser);

        IdsUser = ugNFT.getNftIDsForUser(user1, FIGHT_CLUB_INDEX);

       
        // stakedIdsUser = ugArena.getStakedFighterIDsForUser(user1);
        //   ugGame.levelUpFighters(stakedIdsUser, createAmountsArray(stakedIdsUser.length, 1, 0, 1), true);
        

        hevm.stopPrank();

         hevm.startPrank(user2, user2);
        ugGame.mintFightClubs(1);
        
        IdsUser = ugNFT.getNftIDsForUser(user2, FIGHT_CLUB_INDEX);
        ugGame.mintForges(1);
       
        // stakedIdsUser = ugArena.getStakedFighterIDsForUser(user2);
        //   ugGame.levelUpFighters(stakedIdsUser, createAmountsArray(stakedIdsUser.length, 1, 0, 1), true);
        

        hevm.stopPrank();

         ugWeapons.mint(user2, 2, 100, "");
         ugWeapons.mint(user2, 7, 100, "");
         ugWeapons.mint(user2, 12, 100, "");
         ugWeapons.mint(user2, 17, 100, "");
         ugWeapons.mint(user2, 13, 100, "");
         ugWeapons.mint(user2, 23, 100, "");
         ugWeapons.mint(user2, 33, 100, "");
         ugWeapons.mint(user2, 34, 100, "");

            hevm.warp(100 days);
            (bal, amt) = ugForgeSmith.calculateStakingRewards(ugForgeSmith.getStakedForgeIDsForUser(user1)[0]);
              console.log('weapon',bal);
              console.log('amount',amt);


            hevm.startPrank(user2, user2);
            (bal,) = ugRaid.getUnclaimedWeaponsCount(user2);
                console.log('user 2 weapons to claim', bal);
               // ugRaid.claimWeapons();
                (bal,) = ugRaid.getUnclaimedWeaponsCount(user2);
                console.log('user 2 weapons to claim after claim', bal);

            (bal,) = ugRaid.getUnclaimedWeaponsCount(user1);
            console.log('user 1 weapons to claim', bal);
            
            (bal,) = ugRaid.getUnclaimedWeaponsCount(user3);
            console.log('user 3 weapons to claim', bal);

              ugForgeSmith.equipWeapons(createAmountsArray(2,46,1,100),createAmountsArray(2,23,0,100));
              ugForgeSmith.unEquipWeapons(createAmountsArray(2,46,1,100),createAmountsArray(2,23,0,100));
              ugForgeSmith.upgradeWeapons(createAmountsArray(2,3,10,100), createAmountsArray(2,100,0,200));
              ugForgeSmith.repairWeapons(createAmountsArray(2,32,1,100), createAmountsArray(2,100,0,200));


            hevm.stopPrank();
            hevm.startPrank(user1, user1);
              ugForgeSmith.unstakeForges(ugForgeSmith.getStakedForgeIDsForUser(user1));
            hevm.stopPrank();


   
    }

    function createBoolArray(uint length, bool value) private pure returns (bool[] memory){
        bool[] memory bools = new bool[](length);
        for(uint i; i< length; i++){
            bools[i] = value;
        }
        return bools;
    }
    function createUint8AmountsArray(uint length, uint8 value, uint8 valueIncrement, uint8 modulo) private pure returns (uint8[] memory){
        uint8[] memory amounts = new uint8[](length);
        for(uint i; i< length; i++){
            amounts[i] = uint8(value + (i*valueIncrement)%modulo);
        }
        return amounts;
    }
    function createUint32AmountsArray(uint length, uint32 value, uint8 valueIncrement, uint8 modulo) private pure returns (uint32[] memory){
        uint32[] memory amounts = new uint32[](length);
        for(uint i; i< length; i++){
            amounts[i] = uint32(value + (i*valueIncrement)%modulo);
        }
        return amounts;
    }
    function createAmountsArray(uint length, uint value, uint valueIncrement, uint modulo) private pure returns (uint[] memory){
        uint256[] memory amounts = new uint256[](length);
        for(uint i; i< length; i++){
            amounts[i] = value + (i*valueIncrement)%modulo + valueIncrement;
        }
        return amounts;
    }
    function createRaiderEntries(uint8[] memory size, uint8[] memory yakFamilies, uint32[] memory sweat) private pure returns (IRaidEntry.RaiderEntry[] memory){
        IRaidEntry.RaiderEntry[] memory entries = new IRaidEntry.RaiderEntry[](yakFamilies.length);
        for(uint i; i<yakFamilies.length;i++){
            entries[i].size = size[i];
            entries[i].yakFamily = yakFamilies[i];
            entries[i].sweat = sweat[i]; 
        }
        return entries;
    }

}


