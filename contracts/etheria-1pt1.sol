/*
 
Solidity version: 0.1.6-22723da1/.-Emscripten/clang/int linked to libethereum-1.1.0-d2ef66a9/.-Emscripten/clang/int

bytecode (optimized):

6060604052609d8060106000396000f3606060405260e060020a60003504630878bc51811460245780631bcf5758146040575b005b6106606040526000606090815260699060043590602f60806051565b608360043561036060405260606018815b60008152602001906001900390816051575050919050565b60405180826106008083818460006004609ff15093505050f35b604051808261030080838184600060046057f15093505050f3

var abi = [{"constant":false,"inputs":[{"name":"blocktype","type":"uint8"}],"name":"getAttachesto","outputs":[{"name":"","type":"int8[48]"}],"type":"function"},{"constant":false,"inputs":[{"name":"blocktype","type":"uint8"}],"name":"getOccupies","outputs":[{"name":"","type":"int8[24]"}],"type":"function"}];
var etheria = web3.eth.contract(abi).at('0x169332ae7d143e4b5c6baedb2fef77bfbddb4011');

 */
contract BlockDefStorage 
{
	function getOccupies(uint8 blocktype) public returns (int8[24])
	{}
	function getAttachesto(uint8 blocktype) public returns (int8[48])
    {}
}

contract MapElevationRetriever 
{
	function getElevation(uint8 col, uint8 row) public constant returns (uint8)
	{}
}

contract Etheria 
{
	event TileChanged(uint8 col, uint8 row);//, address owner, string name, string status, uint lastfarm, address[] offerers, uint[] offers, int8[5][] blocks);
	
    uint8 mapsize = 33;
    Tile[33][33] tiles;
    address creator;
    
    struct Tile 
    {
    	address owner;
    	string name;
    	string status;
    	int8[5][] blocks; //0 = blocktype,1 = blockx,2 = blocky,3 = blockz, 4 = color
    	uint lastfarm;
    	int8[3][] occupado; // the only one not reported in the //TileChanged event
    }
    
    BlockDefStorage bds;
    MapElevationRetriever mer;
    
    function Etheria() {
    	creator = tx.origin;
    	bds = BlockDefStorage(0xd4e686a1fbf1bfe058510f07cd3936d3d5a70589); 
    	mer = MapElevationRetriever(0x68549d7dbb7a956f955ec1263f55494f05972a6b);
    }
    
    function getOwner(uint8 col, uint8 row) public constant returns(address)
    {
    	return tiles[col][row].owner; // no harm if col,row are invalid
    }
    
    function setOwner(uint8 col, uint8 row, address newowner)
    {
    	if(tiles[col][row].owner == tx.origin ||
    			(tx.origin == creator && !getLocked()))
    		tiles[col][row].owner = newowner;  // needs whathappened here.
    }
    
    /***
     *     _   _   ___  ___  ___ _____            _____ _____ ___ _____ _   _ _____ 
     *    | \ | | / _ \ |  \/  ||  ___|   ___    /  ___|_   _/ _ \_   _| | | /  ___|
     *    |  \| |/ /_\ \| .  . || |__    ( _ )   \ `--.  | |/ /_\ \| | | | | \ `--. 
     *    | . ` ||  _  || |\/| ||  __|   / _ \/\  `--. \ | ||  _  || | | | | |`--. \
     *    | |\  || | | || |  | || |___  | (_>  < /\__/ / | || | | || | | |_| /\__/ /
     *    \_| \_/\_| |_/\_|  |_/\____/   \___/\/ \____/  \_/\_| |_/\_/  \___/\____/ 
     *                                                                              
     *                                                                              
     */
    
    function getName(uint8 col, uint8 row) public constant returns(string)
    {
    	return tiles[col][row].name; // no harm if col,row are invalid
    }
    function setName(uint8 col, uint8 row, string _n) public
    {
    	Tile tile = tiles[col][row];
    	if(tile.owner != tx.origin && !(tx.origin == creator && !getLocked()))
    	{
    		whathappened = "50:setName:ERR:not owner";  
    		return;
    	}
    	tile.name = _n;
    	TileChanged(col,row);
    	whathappened = "52:setName:SUCCESS";
    	return;
    }
    
    function getStatus(uint8 col, uint8 row) public constant returns(string)
    {
    	return tiles[col][row].status; // no harm if col,row are invalid
    }
    function setStatus(uint8 col, uint8 row, string _s) public // setting status costs 1 eth to prevent spam
    {
    	if(msg.value != 1000000000000000000) 
    	{
    		tx.origin.send(msg.value); 		// return their money
    		whathappened = "41:setStatus:ERR:value was not 1 ETH";
    		return;
    	}
    	Tile tile = tiles[col][row];
    	if(tile.owner != tx.origin && !(tx.origin == creator && !getLocked()))
    	{
    		tx.origin.send(msg.value); 		// return their money
    		whathappened = "43:setStatus:ERR:not owner";  
    		return;
    	}
    	tile.status = _s;
    	creator.send(msg.value);
    	TileChanged(col,row);
    	whathappened = "44:setStatus:SUCCESS";
    	return;
    }
    
    /***
     *    ______ ___  _________  ________ _   _ _____            ___________ _____ _____ _____ _   _ _____ 
     *    |  ___/ _ \ | ___ \  \/  |_   _| \ | |  __ \   ___    |  ___|  _  \_   _|_   _|_   _| \ | |  __ \
     *    | |_ / /_\ \| |_/ / .  . | | | |  \| | |  \/  ( _ )   | |__ | | | | | |   | |   | | |  \| | |  \/
     *    |  _||  _  ||    /| |\/| | | | | . ` | | __   / _ \/\ |  __|| | | | | |   | |   | | | . ` | | __ 
     *    | |  | | | || |\ \| |  | |_| |_| |\  | |_\ \ | (_>  < | |___| |/ / _| |_  | |  _| |_| |\  | |_\ \
     *    \_|  \_| |_/\_| \_\_|  |_/\___/\_| \_/\____/  \___/\/ \____/|___/  \___/  \_/  \___/\_| \_/\____/
     *                                                                                                     
     */
    
    function getLastFarm(uint8 col, uint8 row) public constant returns (uint)
    {
    	return tiles[col][row].lastfarm;
    }
    
    function farmTile(uint8 col, uint8 row, int8 blocktype) public 
    {
    	if(blocktype < 0 || blocktype > 17) // invalid blocktype
    	{
    		whathappened = "34:farmTile:ERR:invalid blocktype";
    		tx.origin.send(msg.value); // in case they sent ether, return it.
    		return;
    	}	
    	
    	Tile tile = tiles[col][row];
        if(tile.owner != tx.origin)
        {
        	whathappened = "31:farmTile:ERR:not owner";
        	tx.origin.send(msg.value); // in case they sent ether, return it.
        	return;
        }
        if((block.number - tile.lastfarm) < 2500) // ~12 hours of blocks
        {
        	if(msg.value != 1000000000000000000)
        	{	
        		tx.origin.send(msg.value); // return their money
        		whathappened = "31:farmTile:ERR:value was not 1 ETH";
        		return;
        	}
        	else // they paid 1 ETH
        	{
        		creator.send(msg.value);
        		// If they haven't waited long enough, but they've paid 1 eth, let them farm again.
        	}	
        }
        else
        {
        	if(msg.value > 0) // they've waited long enough but also sent money. Return it and continue normally.
        	{
        		tx.origin.send(msg.value); // return their money
        	}
        }
        
        // by this point, they've either waited 2500 blocks or paid 1 ETH
    	for(uint8 i = 0; i < 10; i++)
    	{
            tile.blocks.length+=1;
            tile.blocks[tile.blocks.length - 1][0] = int8(blocktype); // blocktype 0-17
    	    tile.blocks[tile.blocks.length - 1][1] = 0; // x
    	    tile.blocks[tile.blocks.length - 1][2] = 0; // y
    	    tile.blocks[tile.blocks.length - 1][3] = -1; // z
    	    tile.blocks[tile.blocks.length - 1][4] = 0; // color
    	}
    	tile.lastfarm = block.number;
    	TileChanged(col,row);
    	whathappened = "33:farmTile:SUCCESS";
    	return;
    }
    
    function editBlock(uint8 col, uint8 row, uint index, int8[5] _block)  
    {
    	Tile tile = tiles[col][row];
        if(tile.owner != tx.origin) // 1. DID THE OWNER SEND THIS MESSAGE?
        {
        	whathappened = "21:editBlock:ERR:not owner";
        	return;
        }
        if(_block[3] < 0) // 2. IS THE Z LOCATION OF THE BLOCK BELOW ZERO? BLOCKS CANNOT BE HIDDEN
        {
        	whathappened = "22:editBlock:ERR:cannot hide blocks";
        	return;
        }
        if(index > (tile.blocks.length-1))
        {
        	whathappened = "23:editBlock:ERR:block index out of range";
        	return;
        }		
        if(_block[0] == -1) // user has signified they want to only change the color of this block
        {
        	tile.blocks[index][4] = _block[4];
        	whathappened = "24:editBlock:SUCCESS:block color changed";
        	return;
        }	
        _block[0] = tile.blocks[index][0]; // can't change the blocktype, so set it to whatever it already was

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
     	}
     	tile.blocks[index] = _block;
     	TileChanged(col,row);
    	return;
    }
       
    function getBlocks(uint8 col, uint8 row) public constant returns (int8[5][])
    {
    	return tiles[col][row].blocks; // no harm if col,row are invalid
    }
   
    /***
     *     _________________ ___________  _____ 
     *    |  _  |  ___|  ___|  ___| ___ \/  ___|
     *    | | | | |_  | |_  | |__ | |_/ /\ `--. 
     *    | | | |  _| |  _| |  __||    /  `--. \
     *    \ \_/ / |   | |   | |___| |\ \ /\__/ /
     *     \___/\_|   \_|   \____/\_| \_|\____/ 
     *                                          
     */
    // three success conditions:
    // 1. Valid offer on unowned tile. (whathap = 4)
    // 2. Valid offer on owned tile where offerer did not previously have an offer on file (whathap = 7)
    // 3. Valid offer on owned tile where offerer DID have a previous offer on file (whathap = 6)
    function buyTile(uint8 col, uint8 row)
    {    	
    	Tile tile = tiles[col][row];
    	if(tile.owner == address(0x0000000000000000000000000000000000000000))			// if UNOWNED
    	{	  
    		if(msg.value != 1000000000000000000 || mer.getElevation(col,row) < 125)	// 1 ETH is the starting value. If not return; // Also, if below sea level, return. 
    		{
    			tx.origin.send(msg.value); 	 									// return their money
    			whathappened = "3:buyTile:ERR:wrong val or water";
    			return;
    		}
    		else
    		{	
    			creator.send(msg.value);     		 					// this was a valid offer, send money to contract creator
    			tile.owner = tx.origin;  								// set tile owner to the buyer
    			TileChanged(col,row);
    			whathappened = "4:buyTile:SUCCESS";
    			return;
    		}
    	}
    	else
    	{
    		whathappened = "5:buyTile:ERR:OOB or already owned";
    		return;
    	}
    }
    
    /***
     *     _   _ _____ _____ _     _____ _______   __
     *    | | | |_   _|_   _| |   |_   _|_   _\ \ / /
     *    | | | | | |   | | | |     | |   | |  \ V / 
     *    | | | | | |   | | | |     | |   | |   \ /  
     *    | |_| | | |  _| |_| |_____| |_  | |   | |  
     *     \___/  \_/  \___/\_____/\___/  \_/   \_/  
     *                                               
     */
    
    // this logic COULD be reduced a little, but the gain is minimal and readability suffers
    function blockHexCoordsValid(int8 x, int8 y) private constant returns (bool)
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
    	
    	if(absy <= 33) // middle rectangle
    	{
    		if(y % 2 != 0 ) // odd
    		{
    			if(-50 <= x && x <= 49)
    				return true;
    		}
    		else // even
    		{
    			if(absx <= 49)
    				return true;
    		}	
    	}	
    	else
    	{	
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
    
    // SEVERAL CHECKS TO BE PERFORMED
    // 1. DID THE OWNER SEND THIS MESSAGE?		(SEE editBlock)
    // 2. IS THE Z LOCATION OF THE BLOCK BELOW ZERO? BLOCKS CANNOT BE HIDDEN AFTER SHOWING	   (SEE editBlock)
    // 3. DO ANY OF THE PROPOSED HEXES FALL OUTSIDE OF THE TILE? 
    // 4. DO ANY OF THE PROPOSED HEXES CONFLICT WITH ENTRIES IN OCCUPADO? 
    // 5. DO ANY OF THE BLOCKS TOUCH ANOTHER?
    // 6. NONE OF THE OCCUPY BLOCKS TOUCHED THE GROUND. BUT MAYBE THEY TOUCH ANOTHER BLOCK?
    
    function isValidLocation(uint8 col, uint8 row, int8[5] _block, int8[24] wouldoccupy) private constant returns (bool)
    {
    	bool touches;
    	Tile tile = tiles[col][row]; // since this is a private method, we don't need to check col,row validity
    	
        for(uint8 b = 0; b < 24; b+=3) // always 8 hexes, calculate the wouldoccupy and the didoccupy
       	{
       		if(!blockHexCoordsValid(wouldoccupy[b], wouldoccupy[b+1])) // 3. DO ANY OF THE PROPOSED HEXES FALL OUTSIDE OF THE TILE? 
      		{
       			whathappened = "10:editBlock:ERR:OOB";
      			return false;
      		}
       		for(uint o = 0; o < tile.occupado.length; o++)  // 4. DO ANY OF THE PROPOSED HEXES CONFLICT WITH ENTRIES IN OCCUPADO? 
          	{
      			if(wouldoccupy[b] == tile.occupado[o][0] && wouldoccupy[b+1] == tile.occupado[o][1] && wouldoccupy[b+2] == tile.occupado[o][2]) // do the x,y,z entries of each match?
      			{
      				whathappened = "11:editBlock:ERR:conflict with another block";
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
          		//attachesto[a] = attachesto[a]+_block[1];
          		attachesto[a+1] = attachesto[a+1]+_block[2];
           		if(attachesto[1] % 2 != 0 && attachesto[a+1] % 2 == 0) // (for attachesto, anchory is the same as for occupies, but the z is different. Nothing to worry about)
           			attachesto[a] = attachesto[a]+1;  			       // then offset x by +1
           		//attachesto[a+2] = attachesto[a+2]+_block[3];
           		for(o = 0; o < tile.occupado.length && !touches; o++)
           		{
           			if((attachesto[a]+_block[1]) == tile.occupado[o][0] && attachesto[a+1] == tile.occupado[o][1] && (attachesto[a+2]+_block[3]) == tile.occupado[o][2]) // a valid attachesto found in occupado?
           			{
           				whathappened = "12:editBlock:SUCCESS:block put on another";
           				return true; // in bounds, didn't conflict and now touches is true. All good. Return.
           			}
           		}
          	}
          	whathappened = "13:editBlock:ERR:floating";
          	return false; 
  		}
        else // touches was true by virtue of a z = 0 above (touching the ground). Return true;
        {
        	whathappened = "14:editBlock:SUCCESS:block put on ground";
        	return true;
        }	
    }  

    string whathappened;
    function getWhatHappened() public constant returns (string)
    {
    	return whathappened;
    }

   /***
    Return money fallback and empty random funds, if any
    */
   function() 
   {
	   tx.origin.send(msg.value);
   }
   
   function empty() 
   {
	   creator.send(address(this).balance); // etheria should never hold a balance. But in case it does, at least provide a way to retrieve them.
   }
    
   /**********
   Standard lock-kill methods 
   **********/
   bool locked;			// until locked, creator can kill, set names, statuses and tile ownership.
   function setLocked()
   {
	   if (msg.sender == creator)
		   locked = true;
   }
   function getLocked() public constant returns (bool)
   {
	   return locked;
   }
   function kill()
   { 
	   if (!getLocked() && msg.sender == creator)
		   suicide(creator);  // kills this contract and sends remaining funds back to creator
   }
}

/*
 
Solidity version: 0.1.6-22723da1/.-Emscripten/clang/int linked to libethereum-1.1.0-d2ef66a9/.-Emscripten/clang/int

bytecode (optimized):

6060604052609d8060106000396000f3606060405260e060020a60003504630878bc51811460245780631bcf5758146040575b005b6106606040526000606090815260699060043590602f60806051565b608360043561036060405260606018815b60008152602001906001900390816051575050919050565b60405180826106008083818460006004609ff15093505050f35b604051808261030080838184600060046057f15093505050f3

var abi = [{"constant":false,"inputs":[],"name":"setLocked","outputs":[],"type":"function"},{"constant":true,"inputs":[],"name":"getWhatHappened","outputs":[{"name":"","type":"uint8"}],"type":"function"},{"constant":true,"inputs":[],"name":"getLocked","outputs":[{"name":"","type":"bool"}],"type":"function"},{"constant":false,"inputs":[],"name":"kill","outputs":[],"type":"function"},{"constant":true,"inputs":[{"name":"_b32","type":"bytes32"},{"name":"byteindex","type":"uint8"}],"name":"getUint8FromByte32","outputs":[{"name":"","type":"uint8"}],"type":"function"},{"constant":false,"inputs":[{"name":"col","type":"uint8"},{"name":"row","type":"uint8"},{"name":"_s","type":"string"}],"name":"setStatus","outputs":[],"type":"function"},{"constant":false,"inputs":[{"name":"col","type":"uint8"},{"name":"row","type":"uint8"}],"name":"makeOffer","outputs":[],"type":"function"},{"constant":true,"inputs":[{"name":"col","type":"uint8"},{"name":"row","type":"uint8"}],"name":"getOfferers","outputs":[{"name":"","type":"address[]"}],"type":"function"},{"constant":false,"inputs":[{"name":"col","type":"uint8"},{"name":"row","type":"uint8"},{"name":"i","type":"uint8"},{"name":"amt","type":"uint256"}],"name":"deleteOffer","outputs":[],"type":"function"},{"constant":true,"inputs":[{"name":"col","type":"uint8"},{"name":"row","type":"uint8"}],"name":"getLastFarm","outputs":[{"name":"","type":"uint256"}],"type":"function"},{"constant":false,"inputs":[{"name":"col","type":"uint8"},{"name":"row","type":"uint8"},{"name":"index","type":"uint256"},{"name":"_block","type":"int8[5]"}],"name":"editBlock","outputs":[],"type":"function"},{"constant":false,"inputs":[{"name":"col","type":"uint8"},{"name":"row","type":"uint8"},{"name":"_n","type":"string"}],"name":"setName","outputs":[],"type":"function"},{"constant":false,"inputs":[{"name":"col","type":"uint8"},{"name":"row","type":"uint8"}],"name":"farmTile","outputs":[],"type":"function"},{"constant":false,"inputs":[{"name":"col","type":"uint8"},{"name":"row","type":"uint8"},{"name":"i","type":"uint8"},{"name":"amt","type":"uint256"}],"name":"acceptOffer","outputs":[],"type":"function"},{"constant":true,"inputs":[{"name":"col","type":"uint8"},{"name":"row","type":"uint8"}],"name":"getName","outputs":[{"name":"","type":"string"}],"type":"function"},{"constant":true,"inputs":[{"name":"col","type":"uint8"},{"name":"row","type":"uint8"}],"name":"getOffers","outputs":[{"name":"","type":"uint256[]"}],"type":"function"},{"constant":true,"inputs":[{"name":"col","type":"uint8"},{"name":"row","type":"uint8"}],"name":"getStatus","outputs":[{"name":"","type":"string"}],"type":"function"},{"constant":true,"inputs":[{"name":"col","type":"uint8"},{"name":"row","type":"uint8"}],"name":"getOwner","outputs":[{"name":"","type":"address"}],"type":"function"},{"constant":true,"inputs":[{"name":"col","type":"uint8"},{"name":"row","type":"uint8"}],"name":"getBlocks","outputs":[{"name":"","type":"int8[5][]"}],"type":"function"},{"inputs":[],"type":"constructor"},{"anonymous":false,"inputs":[{"indexed":false,"name":"col","type":"uint8"},{"indexed":false,"name":"row","type":"uint8"}],"name":"TileChanged","type":"event"}];
var etheria_old = web3.eth.contract(abi).at('0xe414716f017b5c1457bf98e985bccb135dff81f2');
 
var mapsize = 33;

var owners;
owners = new Array(mapsize);
for (i = 0; i < (mapsize - 1); i++) {
    owners[i] = new Array(mapsize);
}

var statuses;
statuses = new Array(mapsize);
for (i = 0; i < mapsize; i++) {
	  statuses[i] = new Array(mapsize);
}

var names;
names = new Array(mapsize);
for (i = 0; i < mapsize; i++) {
	  names[i] = new Array(mapsize);
}

for (var col = 0; col < (mapsize - 1); col++) {
    for (var row = 0; row < (mapsize - 1); row++) {
      owners[col][row] = etheria_old.getOwner(col, row);
      names[col][row] = etheria_old.getName(col,row);
      statuses[col][row] = etheria_old.getStatus(col,row);
      if(owners[col][row] != 0x0000000000000000000000000000000000000000)
              console.log(col + "," + row + " " + owners[col][row] + " name=" + names[col][row] + " status=" + statuses[col][row]);
    }
}

var abi = [{"constant":false,"inputs":[{"name":"blocktype","type":"uint8"}],"name":"getAttachesto","outputs":[{"name":"","type":"int8[48]"}],"type":"function"},{"constant":false,"inputs":[{"name":"blocktype","type":"uint8"}],"name":"getOccupies","outputs":[{"name":"","type":"int8[24]"}],"type":"function"}];
var etheria = web3.eth.contract(abi).at('0x169332ae7d143e4b5c6baedb2fef77bfbddb4011');

var mapsize = 33;

var owners;
owners = new Array(mapsize);
for (i = 0; i < (mapsize - 1); i++) {
    owners[i] = new Array(mapsize);
}

var statuses;
statuses = new Array(mapsize);
for (i = 0; i < mapsize; i++) {
	  statuses[i] = new Array(mapsize);
}

var names;
names = new Array(mapsize);
for (i = 0; i < mapsize; i++) {
	  names[i] = new Array(mapsize);
}

for (var col = 0; col < (mapsize - 1); col++) {
    for (var row = 0; row < (mapsize - 1); row++) {
      owners[col][row] = etheria_old.getOwner(col, row);
      names[col][row] = etheria_old.getName(col,row);
      statuses[col][row] = etheria_old.getStatus(col,row);
      if(owners[col][row] != 0x0000000000000000000000000000000000000000)
              console.log(col + "," + row + " " + owners[col][row] + " name=" + names[col][row] + " status=" + statuses[col][row]);
    }
}

*/
