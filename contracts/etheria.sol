// var abi = [{"constant":false,"inputs":[],"name":"kill","outputs":[],"type":"function"},{"constant":true,"inputs":[{"name":"_b32","type":"bytes32"},{"name":"byteindex","type":"uint8"}],"name":"getUint8FromByte32","outputs":[{"name":"","type":"uint8"}],"type":"function"},{"constant":false,"inputs":[{"name":"col","type":"uint8"},{"name":"row","type":"uint8"},{"name":"_s","type":"string"}],"name":"setStatus","outputs":[],"type":"function"},{"constant":false,"inputs":[{"name":"col","type":"uint8"},{"name":"row","type":"uint8"}],"name":"makeOffer","outputs":[],"type":"function"},{"constant":true,"inputs":[{"name":"col","type":"uint8"},{"name":"row","type":"uint8"}],"name":"getOfferers","outputs":[{"name":"","type":"address[]"}],"type":"function"},{"constant":false,"inputs":[{"name":"col","type":"uint8"},{"name":"row","type":"uint8"},{"name":"index","type":"uint256"},{"name":"_block","type":"int8[5]"}],"name":"editBlock","outputs":[],"type":"function"},{"constant":true,"inputs":[{"name":"col","type":"uint8"},{"name":"row","type":"uint8"}],"name":"getOccupado","outputs":[{"name":"","type":"int8[3][]"}],"type":"function"},{"constant":false,"inputs":[{"name":"col","type":"uint8"},{"name":"row","type":"uint8"},{"name":"_n","type":"string"}],"name":"setName","outputs":[],"type":"function"},{"constant":false,"inputs":[{"name":"col","type":"uint8"},{"name":"row","type":"uint8"}],"name":"farmTile","outputs":[],"type":"function"},{"constant":true,"inputs":[],"name":"getOwners","outputs":[{"name":"","type":"address[33][33]"}],"type":"function"},{"constant":true,"inputs":[{"name":"col","type":"uint8"},{"name":"row","type":"uint8"}],"name":"getName","outputs":[{"name":"","type":"string"}],"type":"function"},{"constant":false,"inputs":[{"name":"col","type":"uint8"},{"name":"row","type":"uint8"},{"name":"i","type":"uint8"}],"name":"acceptOffer","outputs":[],"type":"function"},{"constant":false,"inputs":[{"name":"col","type":"uint8"},{"name":"row","type":"uint8"},{"name":"i","type":"uint8"}],"name":"rejectOffer","outputs":[],"type":"function"},{"constant":true,"inputs":[{"name":"col","type":"uint8"},{"name":"row","type":"uint8"}],"name":"getOffers","outputs":[{"name":"","type":"uint256[]"}],"type":"function"},{"constant":true,"inputs":[{"name":"col","type":"uint8"},{"name":"row","type":"uint8"}],"name":"getStatus","outputs":[{"name":"","type":"string"}],"type":"function"},{"constant":false,"inputs":[{"name":"col","type":"uint8"},{"name":"row","type":"uint8"}],"name":"retractOffer","outputs":[],"type":"function"},{"constant":true,"inputs":[{"name":"col","type":"uint8"},{"name":"row","type":"uint8"}],"name":"getBlocks","outputs":[{"name":"","type":"int8[5][]"}],"type":"function"},{"inputs":[],"type":"constructor"}]
// var etheria = web3.eth.contract(abi).at('0x5dc23a8abc3aa4b5992a4bda54988c9e40887651');

import 'mortal';

contract BlockDefStorage 
{
	function getOccupies(uint8 which) public returns (int8[24])
	{}
	function getAttachesto(uint8 which) public returns (int8[48])
    {}
}

contract MapElevationRetriever 
{
	function getElevation(uint8 col, uint8 row) public constant returns (uint8)
	{}
}

contract Etheria is mortal
{
    uint8 mapsize = 33;
    Tile[33][33] tiles;
    address creator;
        
    struct Tile 
    {
    	address owner;
    	address[] offerers;
    	uint[] offers;
    	int8[5][] blocks; //0 = which,1 = blockx,2 = blocky,3 = blockz, 4 = color
    	uint lastfarm;
    	int8[3][] occupado;
    	string name;
    	string status;
    }
    
    BlockDefStorage bds;
    MapElevationRetriever mer;
    
    function Etheria() {
    	creator = msg.sender;
    	bds = BlockDefStorage(0x782bdf7015b71b64f6750796dd087fde32fd6fdc); 
    	mer = MapElevationRetriever(0xc35a4e966bf792734a25ea524448ea54de385e4e);
    }
    
    function getOwner(uint8 col, uint8 row) public constant returns(address)
    {
    	return tiles[col][row].owner;
    }
    
    function getName(uint8 col, uint8 row) public constant returns(string)
    {
    	return tiles[col][row].name;
    }
    function setName(uint8 col, uint8 row, string _n) public
    {
    	if(tiles[col][row].owner != msg.sender)
    		return;
    	tiles[col][row].name = _n;
    }
    
    function getStatus(uint8 col, uint8 row) public constant returns(string)
    {
    	return tiles[col][row].status;
    }
    function setStatus(uint8 col, uint8 row, string _s) public
    {
    	if(tiles[col][row].owner != msg.sender)
    		return;
    	tiles[col][row].status = _s;
    }
    
    /***
     *    ______                     _   _ _                        _ _ _     _     _            _        
     *    |  ___|                   | | (_) |                      | (_) |   | |   | |          | |       
     *    | |_ __ _ _ __ _ __ ___   | |_ _| | ___  ___      ___  __| |_| |_  | |__ | | ___   ___| | _____ 
     *    |  _/ _` | '__| '_ ` _ \  | __| | |/ _ \/ __|    / _ \/ _` | | __| | '_ \| |/ _ \ / __| |/ / __|
     *    | || (_| | |  | | | | | | | |_| | |  __/\__ \_  |  __/ (_| | | |_  | |_) | | (_) | (__|   <\__ \
     *    \_| \__,_|_|  |_| |_| |_|  \__|_|_|\___||___( )  \___|\__,_|_|\__| |_.__/|_|\___/ \___|_|\_\___/
     *                                                |/                                                  
     *                                                                                                    
     */
    function getUint8FromByte32(bytes32 _b32, uint8 byteindex) public constant returns(uint8) {
    	uint numdigits = 64;
    	uint buint = uint(_b32);
    	uint upperpowervar = 16 ** (numdigits - (byteindex*2)); 		// @i=0 upperpowervar=16**64 (SEE EXCEPTION BELOW), @i=1 upperpowervar=16**62, @i upperpowervar=16**60
    	uint lowerpowervar = 16 ** (numdigits - 2 - (byteindex*2));		// @i=0 upperpowervar=16**62, @i=1 upperpowervar=16**60, @i upperpowervar=16**58
    	uint postheadchop;
    	if(byteindex == 0)
    		postheadchop = buint; 								//for byteindex 0, buint is just the input number. 16^64 is out of uint range, so this exception has to be made.
    	else
    		postheadchop = buint % upperpowervar; 				// @i=0 _b32=a1b2c3d4... postheadchop=a1b2c3d4, @i=1 postheadchop=b2c3d4, @i=2 postheadchop=c3d4
    	uint remainder = postheadchop % lowerpowervar; 			// @i=0 remainder=b2c3d4, @i=1 remainder=c3d4, @i=2 remainder=d4
    	uint evenedout = postheadchop - remainder; 				// @i=0 evenedout=a1000000, @i=1 remainder=b20000, @i=2 remainder=c300
    	uint b = evenedout / lowerpowervar; 					// @i=0 b=a1 (to uint), @i=1 b=b2, @i=2 b=c3
    	return uint8(b);
    }
    
    function farmTile(uint8 col, uint8 row) public 
    {
        if(tiles[col][row].owner != msg.sender)
            return;
        if((block.number - tiles[col][row].lastfarm) < 4320) // a day's worth of blocks hasn't passed yet. can only farm once a day. (Assumes block times of 20 seconds.)
        	return;
        bytes32 lastblockhash = block.blockhash(block.number - 1);
    	for(uint8 i = 0; i < 10; i++)
    	{
            tiles[col][row].blocks.length+=1;
    	    tiles[col][row].blocks[tiles[col][row].blocks.length - 1][0] = int8(getUint8FromByte32(lastblockhash,i) % 32); // which, guaranteed 0-31
    	    tiles[col][row].blocks[tiles[col][row].blocks.length - 1][1] = 0; // x
    	    tiles[col][row].blocks[tiles[col][row].blocks.length - 1][2] = 0; // y
    	    tiles[col][row].blocks[tiles[col][row].blocks.length - 1][3] = -1; // z
    	    tiles[col][row].blocks[tiles[col][row].blocks.length - 1][4] = 0; // color
    	}
    	tiles[col][row].lastfarm = block.number;
    }
    
    // SEVERAL CHECKS TO BE PERFORMED
    // 1. DID THE OWNER SEND THIS MESSAGE?
    // 2. IS THE Z LOCATION OF THE BLOCK BELOW ZERO? BLOCKS CANNOT BE HIDDEN AFTER SHOWING
    // 3. DO ANY OF THE PROPOSED HEXES FALL OUTSIDE OF THE TILE? 
    // 4. DO ANY OF THE PROPOSED HEXES CONFLICT WITH ENTRIES IN OCCUPADO? 
    // 5. DO ANY OF THE BLOCKS TOUCH ANOTHER?
    // 6. NONE OF THE OCCUPY BLOCKS TOUCHED THE GROUND. BUT MAYBE THEY TOUCH ANOTHER BLOCK?
    
//    int8[24] didoccupy;
//    int8[24] wouldoccupy;
//    
//    function getWouldOccupy() public constant returns (int8[24])
//    {
//    	return wouldoccupy;
//    }
//    
//    function getDidOccupy() public constant returns (int8[24])
//    {
//    	return didoccupy;
//    }
    
    function editBlock(uint8 col, uint8 row, uint index, int8[5] _block)  
    {
        if(tiles[col][row].owner != msg.sender) // 1. DID THE OWNER SEND THIS MESSAGE?
        {
        	//whathappened = 1;
        	return;
        }
        if(_block[3] < 0) // 2. IS THE Z LOCATION OF THE BLOCK BELOW ZERO? BLOCKS CANNOT BE HIDDEN
        {
        	//whathappened = 2;
        	return;
        }
        
        _block[0] = tiles[col][row].blocks[index][0]; // can't change the which, so set it to whatever it already was

        int8[24] memory didoccupy = bds.getOccupies(uint8(_block[0]));
        int8[24] memory wouldoccupy = bds.getOccupies(uint8(_block[0]));
        
        for(uint8 b = 0; b < 24; b+=3) // always 8 hexes, calculate the didoccupy
 		{
 			 wouldoccupy[b] = wouldoccupy[b]+_block[1];
 			 wouldoccupy[b+1] = wouldoccupy[b+1]+_block[2];
 			 if(wouldoccupy[1] % 2 != 0 && wouldoccupy[b+1] % 2 == 0) // if anchor y is odd and this hex y is even, (SW NE beam goes 11,`2`2,23,`3`4,35,`4`6,47,`5`8  ` = x value incremented by 1. Same applies to SW NE beam from 01,12,13,24,25,36,37,48)
 				 wouldoccupy[b] = wouldoccupy[b]+1;  			   // then offset x by +1
 			 wouldoccupy[b+2] = wouldoccupy[b+2]+_block[3];
 			 
 			 didoccupy[b] = didoccupy[b]+tiles[col][row].blocks[index][1];
 			 didoccupy[b+1] = didoccupy[b+1]+tiles[col][row].blocks[index][2];
 			 if(didoccupy[1] % 2 != 0 && didoccupy[b+1] % 2 == 0) // if anchor y and this hex y are both odd,
 				 didoccupy[b] = didoccupy[b]+1; 					 // then offset x by +1
       		didoccupy[b+2] = didoccupy[b+2]+tiles[col][row].blocks[index][3];
 		}
        
        if(!isValidLocation(col,row,_block, wouldoccupy))
        {
        	return;
        }
        
        // EVERYTHING CHECKED OUT, WRITE OR OVERWRITE THE HEXES IN OCCUPADO
        
      	if(tiles[col][row].blocks[index][3] >= 0) // If the previous z was greater than 0 (i.e. not hidden) ...
     	{
         	for(uint8 l = 0; l < 24; l+=3) // loop 8 times,find the previous occupado entries and overwrite them
         	{
         		for(uint o = 0; o < tiles[col][row].occupado.length; o++)
         		{
         			if(didoccupy[l] == tiles[col][row].occupado[o][0] && didoccupy[l+1] == tiles[col][row].occupado[o][1] && didoccupy[l+2] == tiles[col][row].occupado[o][2]) // x,y,z equal?
         			{
         				tiles[col][row].occupado[o][0] = wouldoccupy[l]; // found it. Overwrite it
         				tiles[col][row].occupado[o][1] = wouldoccupy[l+1];
         				tiles[col][row].occupado[o][2] = wouldoccupy[l+2];
         			}
         		}
         	}
     	}
     	else // previous block was hidden
     	{
     		for(uint8 ll = 0; ll < 24; ll+=3) // add the 8 new hexes to occupado
         	{
     			tiles[col][row].occupado.length++;
     			tiles[col][row].occupado[tiles[col][row].occupado.length-1][0] = wouldoccupy[ll];
     			tiles[col][row].occupado[tiles[col][row].occupado.length-1][1] = wouldoccupy[ll+1];
     			tiles[col][row].occupado[tiles[col][row].occupado.length-1][2] = wouldoccupy[ll+2];
         	}
     	}
      	
     	tiles[col][row].blocks[index] = _block;
    	return;
    }
       
    function getBlocks(uint8 col, uint8 row) public constant returns (int8[5][])
    {
    	return tiles[col][row].blocks;
    }
    
    function getOccupado(uint8 col, uint8 row) public constant returns (int8[3][])
    {
     	return tiles[col][row].occupado;
    }
    
    function isValidLocation(uint8 col, uint8 row, int8[5] _block, int8[24] wouldoccupy) private constant returns (bool)
    {
    	bool touches;
          
    	//int8[24] memory wouldoccupy = bds.getOccupies(uint8(_block[0]));
    	
        for(uint8 b = 0; b < 24; b+=3) // always 8 hexes, calculate the wouldoccupy and the didoccupy
       	{
//        	wouldoccupy[b] = wouldoccupy[b]+_block[1];
//        	wouldoccupy[b+1] = wouldoccupy[b+1]+_block[2];
//        	if(wouldoccupy[1] % 2 != 0 && wouldoccupy[b+1] % 2 == 0) // if anchor y is odd and this hex y is even, (SW NE beam goes 11,`2`2,23,`3`4,35,`4`6,47,`5`8  ` = x value incremented by 1. Same applies to SW NE beam from 01,12,13,24,25,36,37,48)
//        		wouldoccupy[b] = wouldoccupy[b]+1;  			   // then offset x by +1
//        	wouldoccupy[b+2] = wouldoccupy[b+2]+_block[3];
      			 
       		if(!blockHexCoordsValid(wouldoccupy[b], wouldoccupy[b+1])) // 3. DO ANY OF THE PROPOSED HEXES FALL OUTSIDE OF THE TILE? 
      		{
       			//whathappened = 3;
      			return false;
      		}
       		for(uint o = 0; o < tiles[col][row].occupado.length; o++)  // 4. DO ANY OF THE PROPOSED HEXES CONFLICT WITH ENTRIES IN OCCUPADO? 
          	{
      			if(wouldoccupy[b] == tiles[col][row].occupado[o][0] && wouldoccupy[b+1] == tiles[col][row].occupado[o][1] && wouldoccupy[b+2] == tiles[col][row].occupado[o][2]) // do the x,y,z entries of each match?
      			{
      				//whathappened = 4;
      				return false; // this hex conflicts. The proposed block does not avoid overlap. Return false immediately.
      			}
          	}
      		if(touches == false && wouldoccupy[b+2] == 0)  // 5. DO ANY OF THE BLOCKS TOUCH ANOTHER? (GROUND ONLY FOR NOW)
      		{
      			touches = true; // once true, always true til the end of this method
      		}	
       	}
          
        if(touches == false)  // 6. NONE OF THE OCCUPY BLOCKS TOUCHED THE GROUND. BUT MAYBE THEY TOUCH ANOTHER BLOCK?
  		{
          	int8[48] memory attachesto = bds.getAttachesto(uint8(_block[0]));
          	for(uint8 a = 0; a < 48 && !touches; a+=3) // always 8 hexes, calculate the wouldoccupy and the didoccupy
          	{
          		if(attachesto[a] == 0 && attachesto[a+1] == 0 && attachesto[a+2] == 0) // there are no more attachestos available, break (0,0,0 signifies end)
          			break;
          		attachesto[a] = attachesto[a]+_block[1];
          		attachesto[a+1] = attachesto[a+1]+_block[2];
           		if(attachesto[1] % 2 != 0 && attachesto[a+1] % 2 == 0) // if anchor y and this hex y are both odd,  (for attachesto, anchory is the same as for occupies, but the z is different. Nothing to worry about)
           			attachesto[a] = attachesto[a]+1;  			       // then offset x by +1
           		attachesto[a+2] = attachesto[a+2]+_block[3];
           		for(o = 0; o < tiles[col][row].occupado.length && !touches; o++)
           		{
           			if(attachesto[a] == tiles[col][row].occupado[o][0] && attachesto[a+1] == tiles[col][row].occupado[o][1] && attachesto[a+2] == tiles[col][row].occupado[o][2]) // a valid attachesto found in occupado?
           			{
           				touches = true;
           			}
           		}
          	}
  		}
        
        if(touches == false)
        {
        	//whathappened = 5; // in bounds, didn't conflict, but also didn't touch.
        	return false; 
        }	
        else
        {
        	//whathappened = 6;
        	return true;
        }	
    }
    
    // TODO:
    // DONE block texturing
    // DONE angle camera
    // DONE block edit validation coordinate constraints in JS
    // DONE block edit validation must touch, no overlap in JS
    // DONE block edit validation coordinate constraints in solidity
    // DONE block edit validation must touch, no overlap in solidity
    // DONE block lookup caching 
    // register name for owner
    // register status for owner
   
    // FULL GAME TODO:
    // Fitness vote
    // Cast threat
    // chat
    // messaging
    // block trading
    // reclamation
    // price modifier
    
//    uint8 whathappened;
//    
//    function getWhatHappened() public constant returns (uint8)
//    {
//    	return whathappened;
//    }
    
    function blockHexCoordsValid(int8 x, int8 y) private constant returns (bool)
    {
    	if(-33 <= y && y <= 33)
    	{
    		if(y % 2 != 0 ) // odd
    		{
    			if(-50 <= x && x <= 49)
    				return true;
    			
    		}
    		else // even
    		{
    			if(-49 <= x && x <= 49)
    				return true;
    			
    		}	
    	}	
    	else
    	{	
    		uint8 absx;
			uint8 absy;
			if(x < 0)
				absx = uint8(x*-1);
			else
				absx = uint8(x);
			if(y < 0)
				absy = uint8(y*-1);
			else
				absy = uint8(y);
    		if((y >= 0 && x >= 0) || (y < 0 && x > 0)) // first or 4th quadrants
    		{
    			if(y % 2 != 0 ) // odd
    			{
    				if (((absx*2) + (absy*3)) <= 198)
    					return true;
    				
    			}	
    			else	// even
    			{
    				if ((((absx+1)*2) + ((absy-1)*3)) <= 198)
    					return true;
    				
    			}
    		}
    		else
    		{	
    			if(y % 2 == 0 ) // even
    			{
    				if (((absx*2) + (absy*3)) <= 198)
    					return true;
    				
    			}	
    			else	// odd
    			{
    				if ((((absx+1)*2) + ((absy-1)*3)) <= 198)
    					return true;
    				
    			}
    		}
    	}
    	return false;
    }
    
    /***
     *     _____  __  __              
     *    |  _  |/ _|/ _|             
     *    | | | | |_| |_ ___ _ __ ___ 
     *    | | | |  _|  _/ _ \ '__/ __|
     *    \ \_/ / | | ||  __/ |  \__ \
     *     \___/|_| |_| \___|_|  |___/
     *                                
     *                                
     */
    
    function makeOffer(uint8 col, uint8 row)
    {
    	if(msg.value < 100000000000000000 || msg.value > 1208925819614629174706175) // .1 ether up to (2^80 - 1) wei is the valid range
    	{
    		if(!(msg.value == 0))
    			msg.sender.send(msg.value); 		// return their money
    		return;
    	}
    	else if(tiles[col][row].owner == address(0))								// if UNOWNED
    	{	  // if unowned and above sea level, accept offer of 1 ETH immediately
    		if(msg.value != 1000000000000000000)									// 1 ETH is the starting value. If not return;
    		{
    			msg.sender.send(msg.value); 	 									// return their money
        		return;	
    		}
    		if(mer.getElevation(col,row) < 125)										// if below sea level, return
    		{
    			msg.sender.send(msg.value); 	 									// return their money
        		return;	
    		}
    		creator.send(msg.value);     		 // this was a valid offer, send money to contract owner
    		tiles[col][row].owner = msg.sender;  // set tile owner to the buyer
    		farmTile(col,row); 					 // always immediately farm the tile
    		return;		
    	}	
    	else 																		// if already OWNED
    	{
    		if(tiles[col][row].offerers.length >= 10) 								// this tile can only hold 10 offers at a time and it already has 10
    		{
    			msg.sender.send(msg.value); 	 									// return their money
        		return;	
    		}	
    		for(uint8 i = 0; i < tiles[col][row].offerers.length; i++)
			{
				if(tiles[col][row].offerers[i] == msg.sender) 						// user has already made an offer. Update it and return;
				{
					msg.sender.send(tiles[col][row].offers[i]); 					// return their previous money
					tiles[col][row].offers[i] = msg.value; 							// set the new offer
					return;
				}
			}	
			// the user has not yet made an offer
			tiles[col][row].offerers.length++; // make room for 1 more
			tiles[col][row].offers.length++; // make room for 1 more
			tiles[col][row].offerers[tiles[col][row].offerers.length - 1] = msg.sender; // record who is making the offer
			tiles[col][row].offers[tiles[col][row].offers.length - 1] = msg.value; // record the offer
			return;
    	}
    }
    
    function retractOffer(uint8 col, uint8 row) // retracts the first offer in the array by this user.
    {
        for(uint8 i = 0; i < tiles[col][row].offerers.length; i++)
    	{
    		if(tiles[col][row].offerers[i] == msg.sender) // this user has an offer on file. Remove it.
    			removeOffer(col,row,i);
    	}	
    }
    
    function rejectOffer(uint8 col, uint8 row, uint8 i) // index 0-10
    {
    	if(tiles[col][row].owner != msg.sender) // only the owner can reject offers
    		return;
    	removeOffer(col,row,i);
		return;
    }
    
    function removeOffer(uint8 col, uint8 row, uint8 i) private // index 0-10, can't be odd
    {
    	// return the money
        tiles[col][row].offerers[i].send(tiles[col][row].offers[i]);
    			
    	// delete user and offer and reshape the array
    	delete tiles[col][row].offerers[i];   // zero out user
    	delete tiles[col][row].offers[i];   // zero out offer
    	for(uint8 j = i+1; j < tiles[col][row].offerers.length; j++) // close the arrays after the gap
    	{
    	    tiles[col][row].offerers[j-1] = tiles[col][row].offerers[j];
    	    tiles[col][row].offers[j-1] = tiles[col][row].offers[j];
    	}
    	tiles[col][row].offerers.length--;
    	tiles[col][row].offers.length--;
    	return;
    }
    
    function acceptOffer(uint8 col, uint8 row, uint8 i) // accepts the offer at index (1-10)
    {
    	uint offeramount = tiles[col][row].offers[i];
    	uint housecut = offeramount / 10;
    	creator.send(housecut);
    	tiles[col][row].owner.send(offeramount-housecut); // send offer money to oldowner
    	tiles[col][row].owner = tiles[col][row].offerers[i]; // new owner is the offerer
    	delete tiles[col][row].offerers; // delete all offerers
    	delete tiles[col][row].offers; // delete all offers
    	return;
    }
    
    function getOfferers(uint8 col, uint8 row) constant returns (address[])
    {
    	return tiles[col][row].offerers;
    }
    
    function getOffers(uint8 col, uint8 row) constant returns (uint[])
    {
    	return tiles[col][row].offers;
    }
    
}
// 0x0f8df84b91902100260111b21b02759219358d4f