/*
 * 
var blockdefstorageContract = web3.eth.contract([{"constant":true,"inputs":[{"name":"","type":"uint8"}],"name":"getAttachesto","outputs":[{"name":"","type":"int8[48]"}],"payable":false,"stateMutability":"pure","type":"function"},{"constant":true,"inputs":[{"name":"","type":"uint8"}],"name":"getOccupies","outputs":[{"name":"","type":"int8[24]"}],"payable":false,"stateMutability":"pure","type":"function"}]);
var blockdefstorage = blockdefstorageContract.new(
   {
     from: web3.eth.accounts[0], 
     data: '0x608060405234801561001057600080fd5b506101b7806100206000396000f30060806040526004361061004c576000357c0100000000000000000000000000000000000000000000000000000000900463ffffffff1680630878bc51146100515780631bcf5758146100bd575b600080fd5b34801561005d57600080fd5b5061007f600480360381019080803560ff169060200190929190505050610129565b6040518082603060200280838360005b838110156100aa57808201518184015260208101905061008f565b5050505090500191505060405180910390f35b3480156100c957600080fd5b506100eb600480360381019080803560ff169060200190929190505050610136565b6040518082601860200280838360005b838110156101165780820151818401526020810190506100fb565b5050505090500191505060405180910390f35b610131610143565b919050565b61013e610167565b919050565b61060060405190810160405280603090602082028038833980820191505090505090565b610300604051908101604052806018906020820280388339808201915050905050905600a165627a7a723058207246651602fc6616d28731c6d72856bf6e0e1d60046e29ce563b141dd498e6240029', 
     gas: '4700000'
   }, function (e, contract){
    console.log(e, contract);
    if (typeof contract.address !== 'undefined') {
         console.log('Contract mined! address: ' + contract.address + ' transactionHash: ' + contract.transactionHash);
    }
 })
 */

pragma solidity ^0.4.24;

contract BlockDefStorage 
{
	function getOccupies(uint8) public pure returns (int8[24]) {}
	function getAttachesto(uint8) public pure returns (int8[48]) {}
}

contract MapElevationRetriever 
{
	function getElevation(uint8, uint8) public pure returns (uint8) {}
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
    
    constructor() public {
    	creator = msg.sender;
    	bds = BlockDefStorage(0xd4E686A1FBf1Bfe058510f07Cd3936D3D5A70589); 
    	mer = MapElevationRetriever(0x68549D7Dbb7A956f955Ec1263F55494f05972A6b);
    }
    
    function getOwner(uint8 col, uint8 row) public view returns(address)
    {
    	return tiles[col][row].owner; // no harm if col,row are invalid
    }
    
    function setOwner(uint8 col, uint8 row, address newowner) public
    {
    	Tile storage tile = tiles[col][row];
    	if(tile.owner != msg.sender && !(msg.sender == creator && !getLocked()))
    	{
    		whathappened = "setOwner:ERR:not owner";  
    		return;
    	}
    	tile.owner = newowner;
    	emit TileChanged(col,row);
    	whathappened = "setOwner:OK";
    	return;
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
    
    function getName(uint8 col, uint8 row) public view returns(string)
    {
    	return tiles[col][row].name; // no harm if col,row are invalid
    }
    
    function setName(uint8 col, uint8 row, string _n) public
    {
    	Tile storage tile = tiles[col][row];
    	if(tile.owner != msg.sender && !(msg.sender == creator && !getLocked()))
    	{
    		whathappened = "setName:ERR:not owner";  
    		return;
    	}
    	tile.name = _n;
    	emit TileChanged(col,row);
    	whathappened = "setName:OK";
    	return;
    }
    
    function getStatus(uint8 col, uint8 row) public view returns(string)
    {
    	return tiles[col][row].status; // no harm if col,row are invalid
    }
    
    function setStatus(uint8 col, uint8 row, string _s) public payable // setting status costs .001 eth to prevent spam (if these are echoed by a Twitter feed or something)
    {
    	if(msg.value != 1000000000000000) // .001 eth to set status
    	{
    		msg.sender.transfer(msg.value); 		// return their money, if any
    		whathappened = "setStatus:ERR:val!=.001eth";
    		return;
    	}
    	Tile storage tile = tiles[col][row];
    	if(tile.owner != msg.sender && !(msg.sender == creator && !getLocked()))
    	{
    		msg.sender.transfer(msg.value); 		// return their money, if any
    		whathappened = "setStatus:ERR:not owner";  
    		return;
    	}
    	tile.status = _s;
    	creator.transfer(msg.value);
    	emit TileChanged(col,row);
    	whathappened = "setStatus:OK";
    	return;
    }
    
    /*
     *    ______ ___  _________  ________ _   _ _____            ___________ _____ _____ _____ _   _ _____ 
     *    |  ___/ _ \ | ___ \  \/  |_   _| \ | |  __ \   ___    |  ___|  _  \_   _|_   _|_   _| \ | |  __ \
     *    | |_ / /_\ \| |_/ / .  . | | | |  \| | |  \/  ( _ )   | |__ | | | | | |   | |   | | |  \| | |  \/
     *    |  _||  _  ||    /| |\/| | | | | . ` | | __   / _ \/\ |  __|| | | | | |   | |   | | | . ` | | __ 
     *    | |  | | | || |\ \| |  | |_| |_| |\  | |_\ \ | (_>  < | |___| |/ / _| |_  | |  _| |_| |\  | |_\ \
     *    \_|  \_| |_/\_| \_\_|  |_/\___/\_| \_/\____/  \___/\/ \____/|___/  \___/  \_/  \___/\_| \_/\____/
     *                                                                                                     
     */
    
    function getLastFarm(uint8 col, uint8 row) public view returns (uint)
    {
    	return tiles[col][row].lastfarm;
    }
    
    function farmTile(uint8 col, uint8 row, int8 blocktype) public payable
    {
    	
    	if(blocktype < 0 || blocktype > 17) // invalid blocktype
    	{
    		msg.sender.transfer(msg.value); 		// return their money, if any
    		whathappened = "farmTile:ERR:invalid blocktype";
    		return;
    	}	
    	
    	Tile storage tile = tiles[col][row];
        if(tile.owner != msg.sender)
        {
        	msg.sender.transfer(msg.value); 		// return their money, if any
        	whathappened = "farmTile:ERR:not owner";
        	return;
        }
        if((block.number - tile.lastfarm) < 2500) // ~12 hours of blocks
        {
        	if(msg.value != 1000000000000000) // .001 eth to farm more than once every 2500 blocks
        	{	
        		msg.sender.transfer(msg.value); // return their money
        		whathappened = "farmTile:ERR:val!=.001eth";
        		return;
        	}
        	else // they paid .001 ETH
        	{
        		creator.transfer(msg.value); // If they haven't waited long enough, but they've paid .001 eth, let them farm again.
        	}	
        }
        else
        {
        	if(msg.value > 0) // they've waited long enough but also sent money. Return it and continue normally.
        	{
        		msg.sender.transfer(msg.value); // return their money
        	}
        }
        
        // by this point, they've either waited 2500 blocks or paid .001 ETH
        // allocate 10 blocks for them, all hidden (-1 z) to start
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
    	emit TileChanged(col,row);
    	whathappened = "farmTile:OK";
    	return;
    }
    
    function editBlock(uint8 col, uint8 row, uint index, int8[5] _block) public // does not return $ if sent along. Be careful.  
    {
    	Tile storage tile = tiles[col][row];
        if(tile.owner != msg.sender) // 1. DID THE OWNER SEND THIS MESSAGE?
        {
        	whathappened = "editBlock:ERR:not owner";
        	return;
        }
        if(_block[3] < 0) // 2. IS THE Z LOCATION OF THE BLOCK BELOW ZERO? BLOCKS CANNOT BE HIDDEN
        {
        	whathappened = "editBlock:ERR:can't hide blocks";
        	return;
        }
        if(index > (tile.blocks.length-1))
        {
        	whathappened = "editBlock:ERR:index OOR";
        	return;
        }		
        if(_block[0] == -1) // user has signified they want to only change the color of this block
        {
        	tile.blocks[index][4] = _block[4];
        	whathappened = "editBlock:OK:color changed";
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
     	emit TileChanged(col,row);
    	return;
    }
       
    function getBlocks(uint8 col, uint8 row) public view returns (int8[5][])
    {
    	return tiles[col][row].blocks; // no harm if col,row are invalid
    }
   
    function buyTile(uint8 col, uint8 row) public payable
    {    	
    	if(msg.value != 10000000000000000)	// .01 ETH is the starting value. If not return;  
		{
    		msg.sender.transfer(msg.value);              // return their money, if any
    		whathappened = "buyTile:ERR:val!=.01eth";  
    		return;
		}
    	
    	Tile storage tile = tiles[col][row];
    	if(tile.owner == address(0x0000000000000000000000000000000000000000))			// if UNOWNED
    	{	  
    		if(mer.getElevation(col,row) < 125)	// if below sea level, return. 
    		{
    			msg.sender.transfer(msg.value); 	 									// return their money
    			whathappened = "buyTile:ERR:water";
    			return;
    		}
    		else
    		{	
    			creator.transfer(msg.value);     		 					// this was a valid offer, send money to contract creator
    			tile.owner = msg.sender;  								// set tile owner to the buyer
    			emit TileChanged(col,row);
    			whathappened = "buyTile:OK";
    			return;
    		}
    	}
    	else
    	{
    		msg.sender.transfer(msg.value);              // return their money, if any
    		whathappened = "buyTile:ERR:alr owned";
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
    function blockHexCoordsValid(int8 x, int8 y) private pure returns (bool)
    {
    	uint absx;
		uint absy;
		if(x < 0)
			absx = uint(x*-1);
		else
			absx = uint(x);
		if(y < 0)
			absy = uint(y*-1);
		else
			absy = uint(y);
    	
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
    
    function isValidLocation(uint8 col, uint8 row, int8[5] _block, int8[24] wouldoccupy) private returns (bool)
    {
    	bool touches;
    	Tile storage tile = tiles[col][row]; // since this is a private method, we don't need to check col,row validity
    	
        for(uint8 b = 0; b < 24; b+=3) // always 8 hexes, calculate the wouldoccupy and the didoccupy
       	{
       		if(!blockHexCoordsValid(wouldoccupy[b], wouldoccupy[b+1])) // 3. DO ANY OF THE PROPOSED HEXES FALL OUTSIDE OF THE TILE? 
      		{
       			whathappened = "editBlock:ERR:OOB";
      			return false;
      		}
       		for(uint o = 0; o < tile.occupado.length; o++)  // 4. DO ANY OF THE PROPOSED HEXES CONFLICT WITH ENTRIES IN OCCUPADO? 
          	{
      			if(wouldoccupy[b] == tile.occupado[o][0] && wouldoccupy[b+1] == tile.occupado[o][1] && wouldoccupy[b+2] == tile.occupado[o][2]) // do the x,y,z entries of each match?
      			{
      				whathappened = "editBlock:ERR:conflict";
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
           				whathappened = "editBlock:OK:attached";
           				return true; // in bounds, didn't conflict and now touches is true. All good. Return.
           			}
           		}
          	}
          	whathappened = "editBlock:ERR:floating";
          	return false; 
  		}
        else // touches was true by virtue of a z = 0 above (touching the ground). Return true;
        {
        	whathappened = "editBlock:OK:ground";
        	return true;
        }	
    }  

    string whathappened;
    function getWhatHappened() public view returns (string)
    {
    	return whathappened;
    }

   /***
    Return money fallback and empty random funds, if any
    */
   function() public payable  // is this even necessary anymore? Maybe just "function() public {}"? (without payable, maybe it'll never eat funds?)
   {
	   msg.sender.transfer(msg.value);
   }
   
   function empty() public
   {
	   creator.transfer(address(this).balance); // etheria should never hold a balance. But in case it does, at least provide a way to retrieve them.
   }
    
   /**********
   Standard lock-kill methods 
   **********/
   bool locked;			// until locked, creator can kill, set names, statuses and tile ownership.
   function setLocked() public
   {
	   if (msg.sender == creator)
		   locked = true;
   }
   function getLocked() public view returns (bool)
   {
	   return locked;
   }
   function kill() public 
   { 
	   if (!getLocked() && msg.sender == creator)
		   selfdestruct(creator);  // kills this contract and sends remaining funds back to creator
   }
}