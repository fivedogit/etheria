/**
Etheria testing
**/

// block outside tile
// floating block
// block overlapping another
// rehiding block
// 

// CHECK INITIALIZATION
etheria.getOwners(); 																					// should be all 0x0000000000000000000000000000000000000000 (40 zeros)
checkAllBalances();																						// check balances
etheria.makeOffer.sendTransaction(4,5,{from:eth.accounts[1],gas:2000000,value:web3.toWei(1,'ether')}); 	// 595224 gas used
etheria.getOwners(); 																					// should be all 0x0000000000000000000000000000000000000000 except 8,8 which should be 250000000000000000
web3.fromWei(eth.getBalance(etheria.address)); 															// should be zero, money is sent to creator
checkAllBalances();																						// check balances
//etheria.farmTile.sendTransaction(3,4,{from:eth.accounts[1],gas:2000000}); 							// no need for this now . Blocks automatically farmed on purchase
etheria.getBlocks(4,5); 																				// should be a set of 10 blocks automatically farmed on purchase
etheria.editBlock.sendTransaction(4,5,0,[0,20,20,0,40], {from:eth.accounts[1],gas:2000000}); 			// moves first block to 20,20,0 // 419000 gas used
etheria.editBlock.sendTransaction(4,5,0,[0,20,20,1,40], {from:eth.accounts[1],gas:2000000}); 			// tries to hover the first block // should fail 
etheria.editBlock.sendTransaction(4,5,0,[0,55,55,0,40], {from:eth.accounts[1],gas:2000000}); 			// tries to put a block out of bounds // should fail 
etheria.editBlock.sendTransaction(4,5,1,[0,20,20,0,40], {from:eth.accounts[1],gas:600000}); 			// tries to overlap second block with block at 20,20. // Should fail 
etheria.editBlock.sendTransaction(4,5,1,[0,20,20,1,40], {from:eth.accounts[1],gas:600000}); 			// tries to stack a block // should succeed (Change z to whatever the correct value is depending on the thickness of the block below)

// MAKE SOME INVALID OFFERS
checkAllBalances();																						// check balances
etheria.makeOffer.sendTransaction(8,8,{from:eth.accounts[0],value:99999999999900000, gas:100000}); 		// should fail. 0.0999 ether is too low. .1 is the minimum
etheria.getBlocks(8,8);																					// should be empty array from failed purchase, no farm
checkAllBalances();																						// check balances. Sending account should be slightly less (~.0015) from gas payment, but not .09999 less. That would mean the contract kept the offer money.
web3.fromWei(eth.getBalance(etheria.address)); 															// should still be zero, money is sent to creator
etheria.makeOffer.sendTransaction(0,0,{from:eth.accounts[0],value:1000000000000000000, gas:2000000}); 	// valid amount, but should fail. Can't buy water tiles

// SINGLE OFFER ON A PRE-OWNED TILE
web3.fromWei(eth.getBalance(eth.accounts[0]));															// check purchaser account balance	
web3.fromWei(eth.getBalance(eth.accounts[1]));															// check previous owner account balance
etheria.makeOffer.sendTransaction(8,8,{from:eth.accounts[0],value:1000000000000000000, gas:2000000}); 	// should succeed
etheria.makeOffer.sendTransaction(3,4,{from:eth.accounts[1],value:1000000000000000000, gas:2000000}); 	// should succeed
etheria.getOwners(); // should be all 0x0000000000000000000000000000000000000000 except 8,8 which should be 250000000000000000
web3.fromWei(eth.getBalance(etheria.address)); // should be zero, money is sent to creator
web3.fromWei(eth.getBalance(eth.accounts[0])); // should be + 1
web3.fromWei(eth.getBalance(eth.accounts[1])); // should be - 1

// FARM A TILE
etheria.getBlocks(8,8); // should be empty array
etheria.farmTile.sendTransaction(8,8,{from:eth.coinbase,gas:2000000}); // should generate some random blocks
etheria.getBlocks(8,8); // should be an array of length 7 * 10 = 70
etheria.farmTile.sendTransaction(8,8,{from:eth.coinbase,gas:2000000}); // should fail if it's been less than X blocks.
etheria.getBlocks(8,8); // should be an array of length 7 * 10 = 70

// EDIT blocks
etheria.editBlock.sendTransaction(8,8,0,[0,1,2,3,40], {from:eth.coinbase,gas:2900000});
etheria.getBlocks(8,8); // should show the edited block

// MAKE A VALID OFFER ON AN OWNED TILE
etheria.makeOffer.sendTransaction(8,8, {from:eth.accounts[1],gas:3000000,value:10000000000000000});
etheria.getOfferers(8,8);
etheria.getOffers(8,8);
etheria.makeOffer.sendTransaction(8,8, {from:eth.accounts[1],gas:3000000,value:20000000000000000}); // second offer should update the offer value

// RETRACT OFFER
etheria.retractOffer.sendTransaction(8,8, {from:eth.accounts[1],gas:3000000});

// REJECT OFFER
etheria.rejectOffer.sendTransaction(8,8,0, {from:eth.coinbase,gas:3000000});

// ACCEPT OFFER
etheria.acceptOffer.sendTransaction(8,8,0, {from:eth.accounts[0],gas:3000000});

// MAKE SOME INVALID OFFERS
etheria.makeOffer.sendTransaction(8,8, {from:eth.accounts[1],gas:3000000,value:3000000}); // too low 
etheria.makeOffer.sendTransaction(8,8, {from:eth.accounts[1],gas:3000000,value:12089258196146291747061750}); // too high 

// GET OFFERS FOR THAT TILE
etheria.getOffers(8,8);

// MAKE AN OFFER ON AN UNOWNED TILE (SHOULD FAIL AND RETURN MONEY)
etheria.makeOffer.sendTransaction(2,2, 200000000000000000, {from:eth.coinbase,gas:3000000});

//GET OFFERS FOR THAT TILE
etheria.getOffers(2,2);

// GET OFFERS FOR A TILE

// KILL CONTRACT. DOES IT RETURN VALUE?

//blockdefstorage.initOccupies.sendTransaction(0, [[0,0,0],[0,0,1],[0,0,2],[0,0,3],[0,0,4],[0,0,5],[0,0,6],[0,0,7]],{from:eth.coinbase, gas:500000});
//blockdefstorage.initOccupies.sendTransaction(1, [[0,0,0],[0,1,0],[1,2,0],[1,3,0],[2,4,0],[2,5,0],[3,6,0],[3,7,0]],{from:eth.coinbase, gas:500000});
//blockdefstorage.initOccupies.sendTransaction(2, [[0,0,0],[1,0,0],[2,0,0],[3,0,0],[4,0,0],[5,0,0],[6,0,0],[7,0,0]],{from:eth.coinbase, gas:500000});
//blockdefstorage.initOccupies.sendTransaction(3, [[0,0,0],[-1,1,0],[-1,2,0],[-2,3,0],[-2,4,0],[-3,5,0],[-3,6,0],[-4,7,0]],{from:eth.coinbase, gas:500000});
//blockdefstorage.initOccupies.sendTransaction(4, [[0,0,0],[1,0,0],[1,1,0],[2,1,0],[3,2,0],[4,2,0],[4,3,0],[5,3,0]],{from:eth.coinbase, gas:500000});
//blockdefstorage.initOccupies.sendTransaction(5, [[0,0,0],[-1,0,0],[-2,1,0],[-3,1,0],[-3,2,0],[-4,2,0],[-5,3,0],[-6,3,0]],{from:eth.coinbase, gas:500000});
//blockdefstorage.initOccupies.sendTransaction(6, [[0,0,0],[1,0,0],[0,0,1],[1,0,1],[0,0,2],[1,0,2],[0,0,3],[1,0,3]],{from:eth.coinbase, gas:500000});
//blockdefstorage.initOccupies.sendTransaction(7, [[0,0,0],[0,1,0],[0,0,1],[0,1,1],[0,0,2],[0,1,2],[0,0,3],[0,1,3]],{from:eth.coinbase, gas:500000});
//blockdefstorage.initOccupies.sendTransaction(8, [[0,0,0],[-1,1,0],[0,0,1],[-1,1,1],[0,0,2],[-1,1,2],[0,0,3],[-1,1,3]],{from:eth.coinbase, gas:500000});
//blockdefstorage.initOccupies.sendTransaction(9, [[0,0,0],[0,1,0],[1,2,0],[1,3,0],[0,0,1],[0,1,1],[1,2,1],[1,3,1]],{from:eth.coinbase, gas:500000});
//blockdefstorage.initOccupies.sendTransaction(10, [[0,0,0],[1,0,0],[2,0,0],[3,0,0],[0,0,1],[1,0,1],[2,0,1],[3,0,1]],{from:eth.coinbase, gas:500000});
//blockdefstorage.initOccupies.sendTransaction(11, [[0,0,0],[-1,1,0],[-1,2,0],[-2,3,0],[0,0,1],[-1,1,1],[-1,2,1],[-2,3,1]],{from:eth.coinbase, gas:500000});
//blockdefstorage.initOccupies.sendTransaction(12, [[0,0,0],[1,0,0],[1,1,0],[2,1,0],[0,0,1],[1,0,1],[1,1,1],[2,1,1]],{from:eth.coinbase, gas:500000});
//blockdefstorage.initOccupies.sendTransaction(13, [[0,0,0],[-1,0,0],[-2,1,0],[-3,1,0],[0,0,1],[-1,0,1],[-2,1,1],[-3,1,1]],{from:eth.coinbase, gas:500000});
//blockdefstorage.initOccupies.sendTransaction(14, [[0,0,0],[0,1,0],[0,2,0],[0,3,0],[0,4,0],[0,5,0],[0,6,0],[0,7,0]],{from:eth.coinbase, gas:500000});
//blockdefstorage.initOccupies.sendTransaction(15, [[0,0,0],[-1,1,0],[0,2,0],[-1,3,0],[0,4,0],[-1,5,0],[0,6,0],[-1,7,0]],{from:eth.coinbase, gas:500000});
//blockdefstorage.initOccupies.sendTransaction(16, [[0,0,0],[0,1,0],[0,2,0],[0,3,0],[0,0,1],[0,1,1],[0,2,1],[0,3,1]],{from:eth.coinbase, gas:500000});
//blockdefstorage.initOccupies.sendTransaction(17, [[0,0,0],[-1,1,0],[0,2,0],[-1,3,0],[0,0,1],[-1,1,1],[0,2,1],[-1,3,1]],{from:eth.coinbase, gas:500000});
//blockdefstorage.initOccupies.sendTransaction(18, [[0,0,0],[0,1,0],[0,1,1],[1,2,1],[1,2,2],[1,3,2],[1,3,3],[2,4,3]],{from:eth.coinbase, gas:500000});
//blockdefstorage.initOccupies.sendTransaction(19, [[0,0,0],[1,0,0],[1,0,1],[2,0,1],[2,0,2],[3,0,2],[3,0,3],[4,0,3]],{from:eth.coinbase, gas:500000});
//blockdefstorage.initOccupies.sendTransaction(20, [[0,0,0],[0,-1,0],[0,-1,1],[1,-2,1],[1,-2,2],[1,-3,2],[1,-3,3],[2,-4,3]],{from:eth.coinbase, gas:500000});
//blockdefstorage.initOccupies.sendTransaction(21, [[0,0,0],[-1,-1,0],[-1,-1,1],[-1,-2,1],[-1,-2,2],[-2,-3,2],[-2,-3,3],[-2,-4,3]],{from:eth.coinbase, gas:500000});
//blockdefstorage.initOccupies.sendTransaction(22, [[0,0,0],[-1,0,0],[-1,0,1],[-2,0,1],[-2,0,2],[-3,0,2],[-3,0,3],[-4,0,3]],{from:eth.coinbase, gas:500000});
//blockdefstorage.initOccupies.sendTransaction(23, [[0,0,0],[-1,1,0],[-1,1,1],[-1,2,1],[-1,2,2],[-2,3,2],[-2,3,3],[-2,4,3]],{from:eth.coinbase, gas:500000});
//blockdefstorage.initOccupies.sendTransaction(24, [[0,0,0],[0,0,1],[0,0,2],[0,1,2],[1,2,2],[1,3,2],[1,3,1],[1,3,0]],{from:eth.coinbase, gas:500000});
//blockdefstorage.initOccupies.sendTransaction(25, [[0,0,0],[0,0,1],[0,0,2],[1,0,2],[2,0,2],[3,0,2],[3,0,1],[3,0,0]],{from:eth.coinbase, gas:500000});
//blockdefstorage.initOccupies.sendTransaction(26, [[0,0,0],[0,0,1],[0,0,2],[0,-1,2],[1,-2,2],[1,-3,2],[1,-3,1],[1,-3,0]],{from:eth.coinbase, gas:500000});
//blockdefstorage.initOccupies.sendTransaction(27, [[0,0,0],[0,0,1],[0,0,2],[1,0,2],[1,1,2],[1,2,2],[1,2,1],[1,2,0]],{from:eth.coinbase, gas:500000});
//blockdefstorage.initOccupies.sendTransaction(28, [[0,0,0],[0,0,1],[0,0,2],[-1,-1,2],[0,-2,2],[1,-2,2],[1,-2,1],[1,-2,0]],{from:eth.coinbase, gas:500000});
//blockdefstorage.initOccupies.sendTransaction(29, [[0,0,0],[0,0,1],[0,0,2],[-1,0,2],[-2,-1,2],[-1,-2,2],[-1,-2,1],[-1,-2,0]],{from:eth.coinbase, gas:500000});
//blockdefstorage.initOccupies.sendTransaction(30, [[0,0,0],[0,0,1],[0,0,2],[0,1,2],[0,2,2],[-1,2,2],[-1,2,1],[-1,2,0]],{from:eth.coinbase, gas:500000});
//blockdefstorage.initOccupies.sendTransaction(31, [[0,0,0],[0,0,1],[0,0,2],[0,0,3],[0,0,4],[-1,1,0],[-1,-1,0],[1,0,0]],{from:eth.coinbase, gas:500000});
//
//blockdefstorage.initAttachesto.sendTransaction(0, [[0,0,-1],[0,0,8],[0,0,0],[0,0,0],[0,0,0],[0,0,0],[0,0,0],[0,0,0],[0,0,0],[0,0,0],[0,0,0],[0,0,0],[0,0,0],[0,0,0],[0,0,0],[0,0,0]],{from:eth.coinbase, gas:500000});
//blockdefstorage.initAttachesto.sendTransaction(1, [[0,0,-1],[0,1,-1],[1,2,-1],[1,3,-1],[2,4,-1],[2,5,-1],[3,6,-1],[3,7,-1],[0,0,1],[0,1,1],[1,2,1],[1,3,1],[2,4,1],[2,5,1],[3,6,1],[3,7,1]],{from:eth.coinbase, gas:500000});
//blockdefstorage.initAttachesto.sendTransaction(2, [[0,0,-1],[1,0,-1],[2,0,-1],[3,0,-1],[4,0,-1],[5,0,-1],[6,0,-1],[7,0,-1],[0,0,1],[1,0,1],[2,0,1],[3,0,1],[4,0,1],[5,0,1],[6,0,1],[7,0,1]],{from:eth.coinbase, gas:500000});
//blockdefstorage.initAttachesto.sendTransaction(3, [[0,0,-1],[-1,1,-1],[-1,2,-1],[-2,3,-1],[-2,4,-1],[-3,5,-1],[-3,6,-1],[-4,7,-1],[0,0,1],[-1,1,1],[-1,2,1],[-2,3,1],[-2,4,1],[-3,5,1],[-3,6,1],[-4,7,1]],{from:eth.coinbase, gas:500000});
//blockdefstorage.initAttachesto.sendTransaction(4, [[0,0,-1],[1,0,-1],[1,1,-1],[2,1,-1],[3,2,-1],[4,2,-1],[4,3,-1],[5,3,-1],[0,0,1],[1,0,1],[1,1,1],[2,1,1],[3,2,1],[4,2,1],[4,3,1],[5,3,1]],{from:eth.coinbase, gas:500000});
//blockdefstorage.initAttachesto.sendTransaction(5, [[0,0,-1],[-1,0,-1],[-2,1,-1],[-3,1,-1],[-3,2,-1],[-4,2,-1],[-5,3,-1],[-6,3,-1],[0,0,1],[-1,0,1],[-2,1,1],[-3,1,1],[-3,2,1],[-4,2,1],[-5,3,1],[-6,3,1]],{from:eth.coinbase, gas:500000});
//blockdefstorage.initAttachesto.sendTransaction(6, [[0,0,-1],[1,0,-1],[0,0,4],[1,0,4],[0,0,0],[0,0,0],[0,0,0],[0,0,0],[0,0,0],[0,0,0],[0,0,0],[0,0,0],[0,0,0],[0,0,0],[0,0,0],[0,0,0]],{from:eth.coinbase, gas:500000});
//blockdefstorage.initAttachesto.sendTransaction(7, [[0,0,-1],[0,1,-1],[0,0,4],[0,1,4],[0,0,0],[0,0,0],[0,0,0],[0,0,0],[0,0,0],[0,0,0],[0,0,0],[0,0,0],[0,0,0],[0,0,0],[0,0,0],[0,0,0]],{from:eth.coinbase, gas:500000});
//blockdefstorage.initAttachesto.sendTransaction(8, [[0,0,-1],[-1,1,-1],[0,0,4],[-1,1,4],[0,0,0],[0,0,0],[0,0,0],[0,0,0],[0,0,0],[0,0,0],[0,0,0],[0,0,0],[0,0,0],[0,0,0],[0,0,0],[0,0,0]],{from:eth.coinbase, gas:500000});
//blockdefstorage.initAttachesto.sendTransaction(9, [[0,0,-1],[0,1,-1],[1,2,-1],[1,3,-1],[0,0,2],[0,1,2],[1,2,2],[1,3,2],[0,0,0],[0,0,0],[0,0,0],[0,0,0],[0,0,0],[0,0,0],[0,0,0],[0,0,0]],{from:eth.coinbase, gas:500000});
//blockdefstorage.initAttachesto.sendTransaction(10, [[0,0,-1],[1,0,-1],[2,0,-1],[3,0,-1],[0,0,2],[1,0,2],[2,0,2],[3,0,2],[0,0,0],[0,0,0],[0,0,0],[0,0,0],[0,0,0],[0,0,0],[0,0,0],[0,0,0]],{from:eth.coinbase, gas:500000});
//blockdefstorage.initAttachesto.sendTransaction(11, [[0,0,-1],[-1,1,-1],[-1,2,-1],[-2,3,-1],[0,0,2],[-1,1,2],[-1,2,2],[-2,3,2],[0,0,0],[0,0,0],[0,0,0],[0,0,0],[0,0,0],[0,0,0],[0,0,0],[0,0,0]],{from:eth.coinbase, gas:500000});
//blockdefstorage.initAttachesto.sendTransaction(12, [[0,0,-1],[1,0,-1],[1,1,-1],[2,1,-1],[0,0,2],[1,0,2],[1,1,2],[2,1,2],[0,0,0],[0,0,0],[0,0,0],[0,0,0],[0,0,0],[0,0,0],[0,0,0],[0,0,0]],{from:eth.coinbase, gas:500000});
//blockdefstorage.initAttachesto.sendTransaction(13, [[0,0,-1],[-1,0,-1],[-2,1,-1],[-3,1,-1],[0,0,2],[-1,0,2],[-2,1,2],[-3,1,2],[0,0,0],[0,0,0],[0,0,0],[0,0,0],[0,0,0],[0,0,0],[0,0,0],[0,0,0]],{from:eth.coinbase, gas:500000});
//blockdefstorage.initAttachesto.sendTransaction(14, [[0,0,-1],[0,1,-1],[0,2,-1],[0,3,-1],[0,4,-1],[0,5,-1],[0,6,-1],[0,7,-1],[0,0,1],[0,1,1],[0,2,1],[0,3,1],[0,4,1],[0,5,1],[0,6,1],[0,7,1]],{from:eth.coinbase, gas:500000});
//blockdefstorage.initAttachesto.sendTransaction(15, [[0,0,-1],[-1,1,-1],[0,2,-1],[-1,3,-1],[0,4,-1],[-1,5,-1],[0,6,-1],[-1,7,-1],[0,0,1],[-1,1,1],[0,2,1],[-1,3,1],[0,4,1],[-1,5,1],[0,6,1],[-1,7,1]],{from:eth.coinbase, gas:500000});
//blockdefstorage.initAttachesto.sendTransaction(16, [[0,0,-1],[0,1,-1],[0,2,-1],[0,3,-1],[0,0,2],[0,1,2],[0,2,2],[0,3,2],[0,0,0],[0,0,0],[0,0,0],[0,0,0],[0,0,0],[0,0,0],[0,0,0],[0,0,0]],{from:eth.coinbase, gas:500000});
//blockdefstorage.initAttachesto.sendTransaction(17, [[0,0,-1],[-1,1,-1],[0,2,-1],[-1,3,-1],[0,0,2],[-1,1,2],[0,2,2],[-1,3,1],[0,0,0],[0,0,0],[0,0,0],[0,0,0],[0,0,0],[0,0,0],[0,0,0],[0,0,0]],{from:eth.coinbase, gas:500000});
//blockdefstorage.initAttachesto.sendTransaction(18, [[0,0,-1],[0,1,-1],[1,2,0],[1,3,1],[2,4,2],[0,0,1],[0,1,2],[1,2,3],[1,3,4],[2,4,4],[0,0,0],[0,0,0],[0,0,0],[0,0,0],[0,0,0],[0,0,0]],{from:eth.coinbase, gas:500000});
//blockdefstorage.initAttachesto.sendTransaction(19, [[0,0,-1],[1,0,-1],[2,0,0],[3,0,1],[4,0,2],[0,0,1],[1,0,2],[2,0,3],[3,0,4],[4,0,4],[0,0,0],[0,0,0],[0,0,0],[0,0,0],[0,0,0],[0,0,0]],{from:eth.coinbase, gas:500000});
//blockdefstorage.initAttachesto.sendTransaction(20, [[0,0,-1],[0,-1,-1],[1,-2,0],[1,-3,1],[2,-4,2],[0,0,1],[0,-1,2],[1,-2,3],[1,-3,4],[2,-4,4],[0,0,0],[0,0,0],[0,0,0],[0,0,0],[0,0,0],[0,0,0]],{from:eth.coinbase, gas:500000});
//blockdefstorage.initAttachesto.sendTransaction(21, [[0,0,-1],[-1,-1,-1],[-1,-2,0],[-2,-3,1],[-2,-4,2],[0,0,1],[-1,-1,2],[-1,-2,3],[-2,-3,4],[-2,-4,4],[0,0,0],[0,0,0],[0,0,0],[0,0,0],[0,0,0],[0,0,0]],{from:eth.coinbase, gas:500000});
//blockdefstorage.initAttachesto.sendTransaction(22, [[0,0,-1],[-1,0,-1],[-2,0,0],[-3,0,1],[-4,0,2],[0,0,1],[-1,0,2],[-2,0,3],[-3,0,4],[-4,0,4],[0,0,0],[0,0,0],[0,0,0],[0,0,0],[0,0,0],[0,0,0]],{from:eth.coinbase, gas:500000});
//blockdefstorage.initAttachesto.sendTransaction(23, [[0,0,-1],[-1,1,-1],[-1,2,0],[-2,3,1],[-2,4,2],[0,0,1],[-1,1,2],[-1,2,3],[-2,3,4],[-2,4,4],[0,0,0],[0,0,0],[0,0,0],[0,0,0],[0,0,0],[0,0,0]],{from:eth.coinbase, gas:500000});
//blockdefstorage.initAttachesto.sendTransaction(24, [[0,0,-1],[0,1,1],[1,2,1],[1,3,-1],[0,0,3],[0,1,3],[1,2,3],[1,3,3],[0,0,0],[0,0,0],[0,0,0],[0,0,0],[0,0,0],[0,0,0],[0,0,0],[0,0,0]],{from:eth.coinbase, gas:500000});
//blockdefstorage.initAttachesto.sendTransaction(25, [[0,0,-1],[1,0,1],[2,0,1],[3,0,-1],[0,0,3],[1,0,3],[2,0,3],[3,0,3],[0,0,0],[0,0,0],[0,0,0],[0,0,0],[0,0,0],[0,0,0],[0,0,0],[0,0,0]],{from:eth.coinbase, gas:500000});
//blockdefstorage.initAttachesto.sendTransaction(26, [[0,0,-1],[0,-1,1],[1,-2,1],[1,-3,-1],[0,0,3],[0,-1,3],[1,-2,3],[1,-3,3],[0,0,0],[0,0,0],[0,0,0],[0,0,0],[0,0,0],[0,0,0],[0,0,0],[0,0,0]],{from:eth.coinbase, gas:500000});
//blockdefstorage.initAttachesto.sendTransaction(27, [[0,0,-1],[1,0,1],[1,1,1],[1,2,-1],[0,0,3],[1,0,3],[1,1,3],[1,2,3],[0,0,0],[0,0,0],[0,0,0],[0,0,0],[0,0,0],[0,0,0],[0,0,0],[0,0,0]],{from:eth.coinbase, gas:500000});
//blockdefstorage.initAttachesto.sendTransaction(28, [[0,0,-1],[-1,-1,1],[0,-2,1],[1,-2,-1],[0,0,3],[-1,-1,3],[0,-2,3],[1,-2,3],[0,0,0],[0,0,0],[0,0,0],[0,0,0],[0,0,0],[0,0,0],[0,0,0],[0,0,0]],{from:eth.coinbase, gas:500000});
//blockdefstorage.initAttachesto.sendTransaction(29, [[0,0,-1],[-1,0,1],[-2,-1,1],[-1,-2,-1],[0,0,3],[-1,0,3],[-2,-1,3],[-1,-2,3],[0,0,0],[0,0,0],[0,0,0],[0,0,0],[0,0,0],[0,0,0],[0,0,0],[0,0,0]],{from:eth.coinbase, gas:500000});
//blockdefstorage.initAttachesto.sendTransaction(30, [[0,0,-1],[0,1,1],[0,2,1],[-1,2,-1],[0,0,3],[0,1,3],[0,2,3],[-1,2,3],[0,0,0],[0,0,0],[0,0,0],[0,0,0],[0,0,0],[0,0,0],[0,0,0],[0,0,0]],{from:eth.coinbase, gas:500000});
//blockdefstorage.initAttachesto.sendTransaction(31, [[0,0,-1],[-1,1,-1],[-1,-1,-1],[1,0,-1],[0,0,5],[-1,1,1],[-1,-1,1],[1,0,1],[0,0,0],[0,0,0],[0,0,0],[0,0,0],[0,0,0],[0,0,0],[0,0,0],[0,0,0]],{from:eth.coinbase, gas:500000});

//keeper
//mapelevationstorage.initElevations.sendTransaction(0,[116,116,116,116,116,116,116,116,116,116,116,116,116,116,116,116,116,116,116,116,116,116,116,116,116,116,116,116,116,116,116,116,116], {from:eth.coinbase,gas:3000000});
//mapelevationstorage.initElevations.sendTransaction(1,[116,108,116,114,119,120,127,107,115,96,105,89,116,151,132,145,120,108,110,99,120,93,118,106,115,146,133,140,119,95,106,118,116], {from:eth.coinbase,gas:3000000});
//mapelevationstorage.initElevations.sendTransaction(2,[116,116,117,119,122,130,139,126,114,104,95,105,116,132,149,137,125,115,105,115,125,122,120,117,115,132,150,136,122,109,97,106,116], {from:eth.coinbase,gas:3000000});
//mapelevationstorage.initElevations.sendTransaction(3,[116,111,119,109,125,114,130,110,113,93,105,96,116,151,137,159,129,151,119,144,129,114,122,113,114,99,135,129,125,110,109,91,116], {from:eth.coinbase,gas:3000000});
//mapelevationstorage.initElevations.sendTransaction(4,[116,119,122,125,129,125,121,117,113,114,115,116,117,121,125,129,134,134,134,134,134,129,124,119,114,117,121,125,129,125,122,119,116], {from:eth.coinbase,gas:3000000});
//mapelevationstorage.initElevations.sendTransaction(5,[116,87,103,139,125,97,119,109,112,132,119,120,120,121,135,127,138,119,126,148,133,105,108,85,113,142,126,138,125,132,115,118,116], {from:eth.coinbase,gas:3000000});
//mapelevationstorage.initElevations.sendTransaction(6,[116,100,85,103,121,119,118,114,111,117,123,123,124,134,145,144,143,130,118,125,133,112,92,102,113,122,132,126,121,114,108,112,116], {from:eth.coinbase,gas:3000000});
//mapelevationstorage.initElevations.sendTransaction(7,[116,124,99,97,117,119,114,114,110,110,121,149,127,159,143,179,148,107,130,126,133,93,107,115,113,111,122,138,117,121,111,108,116], {from:eth.coinbase,gas:3000000});
//mapelevationstorage.initElevations.sendTransaction(8,[116,115,114,113,113,112,111,110,110,115,120,125,131,136,142,147,153,148,143,138,133,128,123,118,113,113,113,113,114,114,115,115,116], {from:eth.coinbase,gas:3000000});
//mapelevationstorage.initElevations.sendTransaction(9,[116,107,101,93,113,85,108,98,115,147,132,117,128,129,158,133,157,181,146,172,141,107,125,148,118,131,119,116,120,100,117,93,116], {from:eth.coinbase,gas:3000000});
//mapelevationstorage.initElevations.sendTransaction(10,[116,102,89,101,113,109,106,113,120,132,144,134,125,150,175,168,162,156,150,149,149,138,127,125,123,124,125,125,126,122,119,117,116], {from:eth.coinbase,gas:3000000});
//mapelevationstorage.initElevations.sendTransaction(11,[116,119,101,114,113,106,114,123,125,160,134,114,122,169,160,153,166,144,159,183,157,115,138,104,128,102,130,134,132,151,123,129,116], {from:eth.coinbase,gas:3000000});
//mapelevationstorage.initElevations.sendTransaction(12,[116,115,114,113,113,117,122,126,131,128,125,122,119,132,145,158,171,169,168,167,166,157,149,141,133,134,135,136,138,132,127,121,116], {from:eth.coinbase,gas:3000000});
//mapelevationstorage.initElevations.sendTransaction(13,[116,120,129,139,118,151,131,116,136,165,138,147,132,104,133,170,175,216,184,192,167,178,136,138,138,117,135,114,137,113,139,146,116], {from:eth.coinbase,gas:3000000});
//mapelevationstorage.initElevations.sendTransaction(14,[116,130,145,134,123,131,140,141,142,147,152,148,145,133,122,151,180,190,200,184,168,145,123,133,143,139,135,135,136,144,152,134,116], {from:eth.coinbase,gas:3000000});
//mapelevationstorage.initElevations.sendTransaction(15,[116,119,135,146,128,147,141,154,147,184,157,173,158,124,151,174,185,195,190,197,169,154,142,169,148,148,139,121,135,129,138,100,116], {from:eth.coinbase,gas:3000000});
//mapelevationstorage.initElevations.sendTransaction(16,[116,120,125,129,134,138,143,148,153,157,162,166,171,175,180,185,190,185,180,175,171,166,162,157,153,148,143,138,134,129,125,120,116], {from:eth.coinbase,gas:3000000});
//mapelevationstorage.initElevations.sendTransaction(17,[116,91,121,142,123,117,128,155,150,139,156,200,175,200,178,174,185,157,181,206,173,150,143,128,144,151,130,129,122,97,105,88,116], {from:eth.coinbase,gas:3000000});
//mapelevationstorage.initElevations.sendTransaction(18,[116,117,118,115,112,113,114,131,148,149,150,164,179,177,176,178,180,181,183,179,175,150,125,130,136,127,118,114,110,98,86,101,116], {from:eth.coinbase,gas:3000000});
//mapelevationstorage.initElevations.sendTransaction(19,[116,118,110,110,101,92,115,143,145,136,157,143,183,180,177,216,175,141,179,201,177,148,137,158,128,121,110,123,98,110,93,122,116], {from:eth.coinbase,gas:3000000});
//mapelevationstorage.initElevations.sendTransaction(20,[116,109,103,96,90,103,116,129,143,154,165,176,187,183,179,175,171,173,175,177,179,164,149,134,120,111,103,95,87,94,101,108,116], {from:eth.coinbase,gas:3000000});
//mapelevationstorage.initElevations.sendTransaction(21,[116,126,111,103,98,100,123,120,140,169,156,199,176,208,168,166,166,166,174,139,164,127,131,114,112,126,100,97,90,90,95,117,116], {from:eth.coinbase,gas:3000000});
//mapelevationstorage.initElevations.sendTransaction(22,[116,117,119,113,107,118,130,134,138,142,147,156,165,161,158,160,162,167,173,161,149,131,113,108,104,101,98,96,94,92,90,103,116], {from:eth.coinbase,gas:3000000});
//mapelevationstorage.initElevations.sendTransaction(23,[116,139,119,110,116,99,129,134,136,109,142,119,154,154,153,156,157,158,154,132,134,98,108,100,96,98,96,117,98,92,99,130,116], {from:eth.coinbase,gas:3000000});
//mapelevationstorage.initElevations.sendTransaction(24,[116,118,120,122,125,127,129,131,134,136,138,140,143,145,148,150,153,144,136,128,120,112,104,96,88,91,95,98,102,105,109,112,116], {from:eth.coinbase,gas:3000000});
//mapelevationstorage.initElevations.sendTransaction(25,[116,93,105,108,114,122,116,110,131,104,119,101,136,108,144,147,148,167,136,132,118,102,117,99,91,108,107,117,108,88,105,116,116], {from:eth.coinbase,gas:3000000});
//mapelevationstorage.initElevations.sendTransaction(26,[116,103,91,97,103,103,103,116,129,114,100,115,130,135,140,141,143,139,136,126,117,123,130,112,95,107,120,117,115,108,102,109,116], {from:eth.coinbase,gas:3000000});
//mapelevationstorage.initElevations.sendTransaction(27,[116,99,95,108,92,112,103,100,127,93,110,90,124,150,133,166,138,152,130,133,115,143,119,123,98,115,117,108,121,99,112,94,116], {from:eth.coinbase,gas:3000000});
//mapelevationstorage.initElevations.sendTransaction(28,[116,107,99,90,82,92,103,114,125,123,121,119,118,122,126,130,134,129,124,119,114,111,108,105,102,108,115,121,128,125,122,119,116], {from:eth.coinbase,gas:3000000});
//mapelevationstorage.initElevations.sendTransaction(29,[116,97,101,75,90,88,95,83,122,105,109,115,117,126,115,141,129,129,128,122,114,112,120,112,105,92,119,98,125,122,123,143,116], {from:eth.coinbase,gas:3000000});
//mapelevationstorage.initElevations.sendTransaction(30,[116,109,103,101,99,93,87,103,120,108,97,107,117,110,104,114,125,129,133,124,115,124,133,121,109,116,124,123,122,123,125,120,116], {from:eth.coinbase,gas:3000000});
//mapelevationstorage.initElevations.sendTransaction(31,[116,87,109,101,107,121,101,95,118,114,106,87,116,111,110,96,120,107,124,96,115,127,124,94,112,108,120,112,119,146,120,110,116], {from:eth.coinbase,gas:3000000});
//mapelevationstorage.initElevations.sendTransaction(32,[116,116,116,116,116,116,116,116,116,116,116,116,116,116,116,116,116,116,116,116,116,116,116,116,116,116,116,116,116,116,116,116,116], {from:eth.coinbase,gas:3000000});
