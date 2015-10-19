/* 
var abi = [{"constant":true,"inputs":[],"name":"getWhatHappened","outputs":[{"name":"","type":"uint8"}],"type":"function"},{"constant":false,"inputs":[],"name":"kill","outputs":[],"type":"function"},{"constant":true,"inputs":[{"name":"_b32","type":"bytes32"},{"name":"byteindex","type":"uint8"}],"name":"getUint8FromByte32","outputs":[{"name":"","type":"uint8"}],"type":"function"},{"constant":false,"inputs":[{"name":"col","type":"uint8"},{"name":"row","type":"uint8"},{"name":"_s","type":"string"}],"name":"setStatus","outputs":[],"type":"function"},{"constant":false,"inputs":[{"name":"col","type":"uint8"},{"name":"row","type":"uint8"}],"name":"makeOffer","outputs":[],"type":"function"},{"constant":true,"inputs":[{"name":"col","type":"uint8"},{"name":"row","type":"uint8"}],"name":"getOfferers","outputs":[{"name":"","type":"address[]"}],"type":"function"},{"constant":false,"inputs":[{"name":"col","type":"uint8"},{"name":"row","type":"uint8"},{"name":"index","type":"uint256"},{"name":"_block","type":"int8[5]"}],"name":"editBlock","outputs":[],"type":"function"},{"constant":false,"inputs":[{"name":"col","type":"uint8"},{"name":"row","type":"uint8"},{"name":"_n","type":"string"}],"name":"setName","outputs":[],"type":"function"},{"constant":false,"inputs":[{"name":"col","type":"uint8"},{"name":"row","type":"uint8"}],"name":"farmTile","outputs":[],"type":"function"},{"constant":true,"inputs":[{"name":"col","type":"uint8"},{"name":"row","type":"uint8"}],"name":"getName","outputs":[{"name":"","type":"string"}],"type":"function"},{"constant":false,"inputs":[{"name":"col","type":"uint8"},{"name":"row","type":"uint8"},{"name":"i","type":"uint8"}],"name":"acceptOffer","outputs":[],"type":"function"},{"constant":false,"inputs":[{"name":"col","type":"uint8"},{"name":"row","type":"uint8"},{"name":"i","type":"uint8"}],"name":"rejectOffer","outputs":[],"type":"function"},{"constant":true,"inputs":[{"name":"col","type":"uint8"},{"name":"row","type":"uint8"}],"name":"getOffers","outputs":[{"name":"","type":"uint256[]"}],"type":"function"},{"constant":true,"inputs":[{"name":"col","type":"uint8"},{"name":"row","type":"uint8"}],"name":"getStatus","outputs":[{"name":"","type":"string"}],"type":"function"},{"constant":true,"inputs":[{"name":"col","type":"uint8"},{"name":"row","type":"uint8"}],"name":"getOwner","outputs":[{"name":"","type":"address"}],"type":"function"},{"constant":false,"inputs":[{"name":"col","type":"uint8"},{"name":"row","type":"uint8"}],"name":"retractOffer","outputs":[],"type":"function"},{"constant":true,"inputs":[{"name":"col","type":"uint8"},{"name":"row","type":"uint8"}],"name":"getBlocks","outputs":[{"name":"","type":"int8[5][]"}],"type":"function"},{"inputs":[],"type":"constructor"}];
var etheria = web3.eth.contract(abi).at('0x96b93e5d82cb6546468d3ee1012896b3ce5dc3fe');
*/
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
    	mer = MapElevationRetriever(0x68549d7dbb7a956f955ec1263f55494f05972a6b);
    }
    
    function getOwner(uint8 col, uint8 row) public constant returns(address)
    {
    	return tiles[col][row].owner; // no harm if col,row are invalid
    }
    
    function getName(uint8 col, uint8 row) public constant returns(string)
    {
    	return tiles[col][row].name; // no harm if col,row are invalid
    }
    function setName(uint8 col, uint8 row, string _n) public
    {
    	if(col < 0 || col > (mapsize-1) || row < 0 || row > (mapsize-1)) // row and/or col was not between 0-mapsize
    	{
    		whathappened = 50;
    		return;
    	}
    	Tile tile = tiles[col][row];
    	if(tile.owner != msg.sender)
    	{
    		whathappened = 51;
    		return;
    	}
    	tile.name = _n;
    	whathappened = 52;
    	return;
    }
    
    function getStatus(uint8 col, uint8 row) public constant returns(string)
    {
    	return tiles[col][row].status; // no harm if col,row are invalid
    }
    function setStatus(uint8 col, uint8 row, string _s) public // setting status costs .1 eth. (currently 5 cents. Cry me a river.)
    {
    	if(msg.value == 0)	// the only situation where we don't refund money.
    	{
    		whathappened = 40;
    		return;
    	}
    	if(msg.value != 100000000000000000) // the only situation
    	{
    		msg.sender.send(msg.value); 		// return their money
    		whathappened = 41;
    		return;
    	}
    	if(col < 0 || col > (mapsize-1) || row < 0 || row > (mapsize-1)) // row and/or col was not between 0-mapsize
    	{
    		msg.sender.send(msg.value); 		// return their money
    		whathappened = 42;
    		return;
    	}
    	Tile tile = tiles[col][row];
    	if(tile.owner != msg.sender)
    	{
    		msg.sender.send(msg.value); 		// return their money
    		whathappened = 43;
    		return;
    	}
    	tile.status = _s;
    	whathappened = 44;
    	return;
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
    	if(col < 0 || col > (mapsize-1) || row < 0 || row > (mapsize-1)) // row and/or col was not between 0-mapsize
    	{
    		whathappened = 30;
    		return;
    	}
    	Tile tile = tiles[col][row];
        if(tile.owner != msg.sender)
        {
        	whathappened = 31;
        	return;
        }
        if((block.number - tile.lastfarm) < 4320) // a day's worth of blocks hasn't passed yet. can only farm once a day. (Assumes block times of 20 seconds.)
        {
        	whathappened = 32;
        	return;
        }
        bytes32 lastblockhash = block.blockhash(block.number - 1);
    	for(uint8 i = 0; i < 10; i++)
    	{
            tile.blocks.length+=1;
    	    tile.blocks[tile.blocks.length - 1][0] = int8(getUint8FromByte32(lastblockhash,i) % 32); // which, guaranteed 0-31
    	    tile.blocks[tile.blocks.length - 1][1] = 0; // x
    	    tile.blocks[tile.blocks.length - 1][2] = 0; // y
    	    tile.blocks[tile.blocks.length - 1][3] = -1; // z
    	    tile.blocks[tile.blocks.length - 1][4] = 0; // color
    	}
    	tile.lastfarm = block.number;
    	whathappened = 33;
    	return;
    }
    
    // SEVERAL CHECKS TO BE PERFORMED
    // 1. DID THE OWNER SEND THIS MESSAGE?
    // 2. IS THE Z LOCATION OF THE BLOCK BELOW ZERO? BLOCKS CANNOT BE HIDDEN AFTER SHOWING
    // 3. DO ANY OF THE PROPOSED HEXES FALL OUTSIDE OF THE TILE? 
    // 4. DO ANY OF THE PROPOSED HEXES CONFLICT WITH ENTRIES IN OCCUPADO? 
    // 5. DO ANY OF THE BLOCKS TOUCH ANOTHER?
    // 6. NONE OF THE OCCUPY BLOCKS TOUCHED THE GROUND. BUT MAYBE THEY TOUCH ANOTHER BLOCK?
    
    function editBlock(uint8 col, uint8 row, uint index, int8[5] _block)  
    {
    	if(col < 0 || col > (mapsize-1) || row < 0 || row > (mapsize-1)) // row and/or col was not between 0-mapsize
    	{
    		whathappened = 20;
    		return;
    	}
    	
    	Tile tile = tiles[col][row];
        if(tile.owner != msg.sender) // 1. DID THE OWNER SEND THIS MESSAGE?
        {
        	whathappened = 21;
        	return;
        }
        if(_block[3] < 0) // 2. IS THE Z LOCATION OF THE BLOCK BELOW ZERO? BLOCKS CANNOT BE HIDDEN
        {
        	whathappened = 22;
        	return;
        }
        
        _block[0] = tile.blocks[index][0]; // can't change the which, so set it to whatever it already was

        int8[24] memory didoccupy = bds.getOccupies(uint8(_block[0]));
        int8[24] memory wouldoccupy = bds.getOccupies(uint8(_block[0]));
        
        for(uint8 b = 0; b < 24; b+=3) // always 8 hexes, calculate the didoccupy
 		{
 			 wouldoccupy[b] = wouldoccupy[b]+_block[1];
 			 wouldoccupy[b+1] = wouldoccupy[b+1]+_block[2];
 			 if(wouldoccupy[1] % 2 != 0 && wouldoccupy[b+1] % 2 == 0) // if anchor y is odd and this hex y is even, (SW NE beam goes 11,`2`2,23,`3`4,35,`4`6,47,`5`8  ` = x value incremented by 1. Same applies to SW NE beam from 01,12,13,24,25,36,37,48)
 				 wouldoccupy[b] = wouldoccupy[b]+1;  			   // then offset x by +1
 			 wouldoccupy[b+2] = wouldoccupy[b+2]+_block[3];
 			 
 			 didoccupy[b] = didoccupy[b]+tile.blocks[index][1];
 			 didoccupy[b+1] = didoccupy[b+1]+tile.blocks[index][2];
 			 if(didoccupy[1] % 2 != 0 && didoccupy[b+1] % 2 == 0) // if anchor y and this hex y are both odd,
 				 didoccupy[b] = didoccupy[b]+1; 					 // then offset x by +1
       		didoccupy[b+2] = didoccupy[b+2]+tile.blocks[index][3];
 		}
        
        if(!isValidLocation(col,row,_block, wouldoccupy))
        {
        	return; // whathappened is already set
        }
        
        // EVERYTHING CHECKED OUT, WRITE OR OVERWRITE THE HEXES IN OCCUPADO
        
      	if(tile.blocks[index][3] >= 0) // If the previous z was greater than 0 (i.e. not hidden) ...
     	{
         	for(uint8 l = 0; l < 24; l+=3) // loop 8 times,find the previous occupado entries and overwrite them
         	{
         		for(uint o = 0; o < tile.occupado.length; o++)
         		{
         			if(didoccupy[l] == tile.occupado[o][0] && didoccupy[l+1] == tile.occupado[o][1] && didoccupy[l+2] == tile.occupado[o][2]) // x,y,z equal?
         			{
         				tile.occupado[o][0] = wouldoccupy[l]; // found it. Overwrite it
         				tile.occupado[o][1] = wouldoccupy[l+1];
         				tile.occupado[o][2] = wouldoccupy[l+2];
         			}
         		}
         	}
         	//whathappened = 23;
     	}
     	else // previous block was hidden
     	{
     		for(uint8 ll = 0; ll < 24; ll+=3) // add the 8 new hexes to occupado
         	{
     			tile.occupado.length++;
     			tile.occupado[tile.occupado.length-1][0] = wouldoccupy[ll];
     			tile.occupado[tile.occupado.length-1][1] = wouldoccupy[ll+1];
     			tile.occupado[tile.occupado.length-1][2] = wouldoccupy[ll+2];
         	}
     		//whathappened = 24;
     	}
     	tile.blocks[index] = _block;
    	return;
    }
       
    function getBlocks(uint8 col, uint8 row) public constant returns (int8[5][])
    {
    	return tiles[col][row].blocks; // no harm if col,row are invalid
    }
   
    // TODO -- not necessary
//    function getOccupado(uint8 col, uint8 row) public constant returns (int8[3][])
//    {
//     	return tiles[col][row].occupado; // no harm if col,row are invalid
//    }
    
    function isValidLocation(uint8 col, uint8 row, int8[5] _block, int8[24] wouldoccupy) private constant returns (bool)
    {
    	bool touches;
    	Tile tile = tiles[col][row]; // since this is a private method, we don't need to check col,row validity
    	
        for(uint8 b = 0; b < 24; b+=3) // always 8 hexes, calculate the wouldoccupy and the didoccupy
       	{
       		if(!blockHexCoordsValid(wouldoccupy[b], wouldoccupy[b+1])) // 3. DO ANY OF THE PROPOSED HEXES FALL OUTSIDE OF THE TILE? 
      		{
       			whathappened = 10;
      			return false;
      		}
       		for(uint o = 0; o < tile.occupado.length; o++)  // 4. DO ANY OF THE PROPOSED HEXES CONFLICT WITH ENTRIES IN OCCUPADO? 
          	{
      			if(wouldoccupy[b] == tile.occupado[o][0] && wouldoccupy[b+1] == tile.occupado[o][1] && wouldoccupy[b+2] == tile.occupado[o][2]) // do the x,y,z entries of each match?
      			{
      				whathappened = 11;
      				return false; // this hex conflicts. The proposed block does not avoid overlap. Return false immediately.
      			}
          	}
      		if(touches == false && wouldoccupy[b+2] == 0)  // 5. DO ANY OF THE BLOCKS TOUCH ANOTHER? (GROUND ONLY FOR NOW)
      		{
      			touches = true; // once true, always true til the end of this method. We must keep looping to check all the hexes for conflicts and tile boundaries, though, so we can't return true here.
      		}	
       	}
        
        // now if we're out of the loop and here, there were no conflicts and the block was found to be in the tile boundary.
        // touches may be true or false, so we need to check 
          
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
           		for(o = 0; o < tile.occupado.length && !touches; o++)
           		{
           			if(attachesto[a] == tile.occupado[o][0] && attachesto[a+1] == tile.occupado[o][1] && attachesto[a+2] == tile.occupado[o][2]) // a valid attachesto found in occupado?
           			{
           				whathappened = 12;
           				return true; // in bounds, didn't conflict and now touches is true. All good. Return.
           			}
           		}
          	}
          	whathappened = 13;
          	return false; 
  		}
        else // touches was true by virtue of a z = 0 above (touching the ground). Return true;
        {
        	whathappened = 14;
        	return true;
        }	
    }   
   
    // FULL GAME TODO:
    // Fitness vote
    // Cast threat
    // chat
    // messaging
    // block trading
    // reclamation
    // price modifier
    
    // this logic COULD be reduced a little, but the gain is minimal and readability suffers
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
    
    uint8 whathappened;
    
    function getWhatHappened() public constant returns (uint8)
    {
    	return whathappened;
    }
    
    function makeOffer(uint8 col, uint8 row)
    {
    	if(msg.value == 0) // checking this first means that we will ALWAYS need to return money on any other failure
    	{
    		whathappened = 1;
    		return;
    	}	// do nothing, just return
    	
    	if(col < 0 || col > (mapsize-1) || row < 0 || row > (mapsize-1)) // row and/or col was not between 0-mapsize
    	{
    		whathappened = 2;
    		msg.sender.send(msg.value); 		// return their money
    		return;
    	}
    	
    	Tile tile = tiles[col][row];
    	if(tile.owner == address(0x0000000000000000000000000000000000000000))			// if UNOWNED
    	{	  
    		if(msg.value != 1000000000000000000 || mer.getElevation(col,row) < 125)	// 1 ETH is the starting value. If not return; // Also, if below sea level, return. 
    		{
    			msg.sender.send(msg.value); 	 									// return their money
    			whathappened = 3;
    			return;
    		}
    		else
    		{	
    			creator.send(msg.value);     		 								// this was a valid offer, send money to contract creator
    			tile.owner = msg.sender;  								// set tile owner to the buyer
    			whathappened = 4;
    			return;
    		}
    	}	
    	else 																		// if already OWNED
    	{
    		if(tile.owner == msg.sender || msg.value < 10000000000000000 || msg.value > 1000000000000000000000000 || tile.offerers.length >= 10 ) // trying to make an offer on their own tile. or the offer list is full (10 max) or the value is out of range (.01 ETH - 1 mil ETH is range)
    		{
    			msg.sender.send(msg.value); 	 									// return the money
    			whathappened = 5;
    			return;
    		}
    		else
    		{	
    			for(uint8 i = 0; i < tile.offerers.length; i++)
    			{
    				if(tile.offerers[i] == msg.sender) 						// user has already made an offer. Update it and return;
    				{
    					msg.sender.send(tile.offers[i]); 					// return their previous money
    					tile.offers[i] = msg.value; 							// set the new offer
    					whathappened = 6;
    					return;
    				}
    			}	
    			// the user has not yet made an offer
    			tile.offerers.length++; // make room for 1 more
    			tile.offers.length++; // make room for 1 more
    			tile.offerers[tile.offerers.length - 1] = msg.sender; // record who is making the offer
    			tile.offers[tile.offers.length - 1] = msg.value; // record the offer
    			whathappened = 7;
    			return;
    		}
    	}
    }
    
    function retractOffer(uint8 col, uint8 row) // retracts the first offer in the array by this user.
    {
    	if(col < 0 || col > (mapsize-1) || row < 0 || row > (mapsize-1)) // row and/or col was not between 0-mapsize
    	{
    		whathappened = 60;
    		return;
    	}
    	Tile tile = tiles[col][row];
        for(uint8 i = 0; i < tile.offerers.length; i++)
    	{
    		if(tile.offerers[i] == msg.sender) // this user has an offer on file. Remove it.
    		{
    			whathappened = 61;
    			removeOffer(col,row,i);
    			return;
    		}
    	}	
        whathappened = 62; // no offer found for msg.sender
        return;
    }
    
    function rejectOffer(uint8 col, uint8 row, uint8 i) // index 0-10
    {
    	if(col < 0 || col > (mapsize-1) || row < 0 || row > (mapsize-1)) // row and/or col was not between 0-mapsize
    	{
    		whathappened = 70;
    		return;
    	}
    	Tile tile = tiles[col][row];
    	if(tile.owner != msg.sender) // only the owner can reject offers
    	{
    		whathappened = 71;
    		return;
    	}
    	if(i < 0 || i > (tile.offers.length - 1)) // index oob
    	{
    		whathappened = 72;
    		return;
    	}	
    	removeOffer(col,row,i);
    	whathappened = 73;
		return;
    }
    
    function removeOffer(uint8 col, uint8 row, uint8 i) private // index 0-10, can't be odd
    {
    	Tile tile = tiles[col][row]; // private method. No need to check col,row validity
        tile.offerers[i].send(tile.offers[i]); // return the money
    			
    	// delete user and offer and reshape the array
    	delete tile.offerers[i];   // zero out user
    	delete tile.offers[i];   // zero out offer
    	for(uint8 j = i+1; j < tile.offerers.length; j++) // close the arrays after the gap
    	{
    	    tile.offerers[j-1] = tile.offerers[j];
    	    tile.offers[j-1] = tile.offers[j];
    	}
    	tile.offerers.length--;
    	tile.offers.length--;
    	return;
    }
    
    function acceptOffer(uint8 col, uint8 row, uint8 i) // accepts the offer at index (1-10)
    {
    	if(col < 0 || col > (mapsize-1) || row < 0 || row > (mapsize-1)) // row and/or col was not between 0-mapsize
    	{
    		whathappened = 80;
    		return;
    	}
    	
    	Tile tile = tiles[col][row];
    	if(tile.owner != msg.sender) // only the owner can reject offers
    	{
    		whathappened = 81;
    		return;
    	}
    	if(i < 0 || i > (tile.offers.length - 1)) // index oob
    	{
    		whathappened = 82;
    		return;
    	}	
    	uint offeramount = tile.offers[i];
    	uint housecut = offeramount / 10;
    	creator.send(housecut);
    	tile.owner.send(offeramount-housecut); // send offer money to oldowner
    	tile.owner = tile.offerers[i]; // new owner is the offerer
    	for(uint8 j = 0; j < tile.offerers.length; j++) // return all the other offerers' offer money
    	{
    		if(j != i) // don't return money for the purchaser
    			tile.offerers[j].send(tile.offers[j]);
    	}
    	delete tile.offerers; // delete all offerers
    	delete tile.offers; // delete all offers
    	whathappened = 83;
    	return;
    }
    
    function getOfferers(uint8 col, uint8 row) constant returns (address[])
    {
    	return tiles[col][row].offerers; // no harm if col,row are invalid
    }
    
    function getOffers(uint8 col, uint8 row) constant returns (uint[])
    {
    	return tiles[col][row].offers; // no harm if col,row are invalid
    }
}