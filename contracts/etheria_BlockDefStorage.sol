contract BlockDefStorage
{
	bool[32] occupiesInitialized;
	bool[32] attachestoInitialized;
	bool allOccupiesInitialized;
	bool allAttachestoInitialized;
	
    Block[20] blocks;
    struct Block
    {
    	int8[3][8] occupies; // [x,y,z] 8 times
    	int8[3][] attachesto; // [x,y,z]
    }
    
    function getOccupies(uint8 which) public constant returns (int8[3][8])
    {
    	return blocks[which].occupies;
    }
    
    function getAttachesto(uint8 which) public constant returns (int8[3][])
    {
    	return blocks[which].attachesto;
    }
    
    function initOccupies(uint8 which, int8[3][8] occupies) public 
    {
    	if(allOccupiesInitialized) // lockout
    		return;
    	blocks[which].occupies = occupies;
    	occupiesInitialized[which] == true;
    	for(uint8 b = 0; b < 32; b++)
    	{
    		if(occupiesInitialized[b] == false)
    			return;
    	}	
    	allOccupiesInitialized = true;
    }
    
    function initAttachesto(uint8 which, int8[3][] attachesto) public
    {
    	if(allAttachestoInitialized) // lockout
    		return;
    	blocks[which].attachesto.length = attachesto.length;
    	blocks[which].attachesto = attachesto;
    	attachestoInitialized[which] = true;
    	for(uint8 b = 0; b < 32; b++)
    	{
    		if(attachestoInitialized[b] == false)
    			return;
    	}	
    	allAttachestoInitialized = true;
    }
    
}

// compiled and deployed with:

/*
 0.1.5-e11e10f8/.-Emscripten/clang/int linked to libethereum-
 
 bytecode:
 
 60606040526106a3806100126000396000f3606060405260e060020a60003504630878bc51811461003c5780631256c698146100f3578063197bcde7146101515780631bcf5758146101c2575b005b61029a60043560408051602081019091526000815260038260148110156100025790906009020160005060080180546040805160208381028201810190925282815292919060009084015b82821015610375576000848152602081206040805160608101918290529291850191600391908390855b825461010083900a900460000b8152602060019283018181049485019490930390920291018084116100b1579050505050505081526020019060010190610087565b60408051610100810190915261003a90600480359161032490602460086000835b828210156102f557604080516060818101909252908381028601906003908390839080828437820191505050505081526020019060010190610114565b604080516024803560048181013560208181028601810190965280855261003a958235959294604494019190819060009085015b8282101561031057604080516060818101909252908381028701906003908390839080828437820191505050505081526020019060010190610185565b610331600435610300604051908101604052806008905b6060604051908101604052806003905b60008152602001906001900390816101e9579050508152602001906001900390816101d957506003905082601481101561000257600902016000506040805161010081019091529060086000835b82821015610375576040805160608101918290529085840190600390826000855b825461010083900a900460000b815260206001928301818104948501949093039092029101808411610258579050505050505081526020019060010190610237565b60405180806020018281038252838181518152602001915080516000925b818410156102e457602084810284010151606080838184600060046018f15090500192600101926102b8565b925050509250505060405180910390f35b509294505050505060025460009060ff16156103935761038e565b509395505050505050600254600090610100900460ff16156104e25761038e565b6040516000826008835b818410156103655760208402830151606080838184600060046018f150905001926001019261033b565b9250505091505060405180910390f35b505050509050919050565b6002805460ff191660011790555b505050565b81600384601481101561000257506009850290810191600b91909101908261010082015b8281111561041457825182906001820190826060820160005b8382111561045157835183826101000a81548160ff021916908360f860020a90810204021790555092602001926001016020816000010492830192600103026103d0565b506104939291505b8082111561048f576000815560010161041c565b505061047e9291505b8082111561048f57805460ff19168155600101610439565b80156104305782816101000a81549060ff0219169055600101602081600001049283019260010302610451565b5050916020019190600101906103b7565b5090565b5060009050836020811015610002575090505b60208160ff1610156103805760008160208110156100025760208082045491066101000a900460ff1614156104da5761038e565b6001016104a6565b815160038460148110156100025760090201600050600801600050818154818355818115116105225760008381526020902061052291810190830161041c565b50505050816003600050846014811015610002578251600991909102600b0180548282556000828152602090819020929591830194500182156105c3579160200282015b828111156105c357825182906001820190826060820160005b838211156105dc57835183826101000a81548160ff021916908360f860020a908102040217905550926020019260010160208160000104928301926001030261057f565b5061061a92915061041c565b5050610609929150610439565b80156105cf5782816101000a81549060ff02191690556001016020816000010492830192600103026105dc565b505091602001919060010190610566565b5060019050808460208110156100025760208082049092019190066101000a81548160ff02191690830217905550600090505b60208160ff161015610687576001816020811015610002576020808204909201549190066101000a900460ff166000141561069b5761038e565b6002805461ff001916610100179055505050565b60010161064d56
 
 abi 
 
 [{"constant":true,"inputs":[{"name":"which","type":"uint8"}],"name":"getAttachesto","outputs":[{"name":"","type":"int8[3][]"}],"type":"function"},{"constant":false,"inputs":[{"name":"which","type":"uint8"},{"name":"occupies","type":"int8[3][8]"}],"name":"initOccupies","outputs":[],"type":"function"},{"constant":false,"inputs":[{"name":"which","type":"uint8"},{"name":"attachesto","type":"int8[3][]"}],"name":"initAttachesto","outputs":[],"type":"function"},{"constant":true,"inputs":[{"name":"which","type":"uint8"}],"name":"getOccupies","outputs":[{"name":"","type":"int8[3][8]"}],"type":"function"}]

web3 deploy 

var blockdefstorageContract = web3.eth.contract([{"constant":true,"inputs":[{"name":"which","type":"uint8"}],"name":"getAttachesto","outputs":[{"name":"","type":"int8[3][]"}],"type":"function"},{"constant":false,"inputs":[{"name":"which","type":"uint8"},{"name":"occupies","type":"int8[3][8]"}],"name":"initOccupies","outputs":[],"type":"function"},{"constant":false,"inputs":[{"name":"which","type":"uint8"},{"name":"attachesto","type":"int8[3][]"}],"name":"initAttachesto","outputs":[],"type":"function"},{"constant":true,"inputs":[{"name":"which","type":"uint8"}],"name":"getOccupies","outputs":[{"name":"","type":"int8[3][8]"}],"type":"function"}]);
var blockdefstorage = blockdefstorageContract.new(
   {
     from: web3.eth.accounts[0], 
     data: '60606040526106a3806100126000396000f3606060405260e060020a60003504630878bc51811461003c5780631256c698146100f3578063197bcde7146101515780631bcf5758146101c2575b005b61029a60043560408051602081019091526000815260038260148110156100025790906009020160005060080180546040805160208381028201810190925282815292919060009084015b82821015610375576000848152602081206040805160608101918290529291850191600391908390855b825461010083900a900460000b8152602060019283018181049485019490930390920291018084116100b1579050505050505081526020019060010190610087565b60408051610100810190915261003a90600480359161032490602460086000835b828210156102f557604080516060818101909252908381028601906003908390839080828437820191505050505081526020019060010190610114565b604080516024803560048181013560208181028601810190965280855261003a958235959294604494019190819060009085015b8282101561031057604080516060818101909252908381028701906003908390839080828437820191505050505081526020019060010190610185565b610331600435610300604051908101604052806008905b6060604051908101604052806003905b60008152602001906001900390816101e9579050508152602001906001900390816101d957506003905082601481101561000257600902016000506040805161010081019091529060086000835b82821015610375576040805160608101918290529085840190600390826000855b825461010083900a900460000b815260206001928301818104948501949093039092029101808411610258579050505050505081526020019060010190610237565b60405180806020018281038252838181518152602001915080516000925b818410156102e457602084810284010151606080838184600060046018f15090500192600101926102b8565b925050509250505060405180910390f35b509294505050505060025460009060ff16156103935761038e565b509395505050505050600254600090610100900460ff16156104e25761038e565b6040516000826008835b818410156103655760208402830151606080838184600060046018f150905001926001019261033b565b9250505091505060405180910390f35b505050509050919050565b6002805460ff191660011790555b505050565b81600384601481101561000257506009850290810191600b91909101908261010082015b8281111561041457825182906001820190826060820160005b8382111561045157835183826101000a81548160ff021916908360f860020a90810204021790555092602001926001016020816000010492830192600103026103d0565b506104939291505b8082111561048f576000815560010161041c565b505061047e9291505b8082111561048f57805460ff19168155600101610439565b80156104305782816101000a81549060ff0219169055600101602081600001049283019260010302610451565b5050916020019190600101906103b7565b5090565b5060009050836020811015610002575090505b60208160ff1610156103805760008160208110156100025760208082045491066101000a900460ff1614156104da5761038e565b6001016104a6565b815160038460148110156100025760090201600050600801600050818154818355818115116105225760008381526020902061052291810190830161041c565b50505050816003600050846014811015610002578251600991909102600b0180548282556000828152602090819020929591830194500182156105c3579160200282015b828111156105c357825182906001820190826060820160005b838211156105dc57835183826101000a81548160ff021916908360f860020a908102040217905550926020019260010160208160000104928301926001030261057f565b5061061a92915061041c565b5050610609929150610439565b80156105cf5782816101000a81549060ff02191690556001016020816000010492830192600103026105dc565b505091602001919060010190610566565b5060019050808460208110156100025760208082049092019190066101000a81548160ff02191690830217905550600090505b60208160ff161015610687576001816020811015610002576020808204909201549190066101000a900460ff166000141561069b5761038e565b6002805461ff001916610100179055505050565b60010161064d56', 
     gas: 3000000
   }, function(e, contract){
    if (typeof contract.address != 'undefined') {
         console.log(e, contract);
         console.log('Contract mined! address: ' + contract.address + ' transactionHash: ' + contract.transactionHash);
    }
 })
 
 uDApp
 
 [{"name":"BlockDefStorage","interface":"[{\"constant\":true,\"inputs\":[{\"name\":\"which\",\"type\":\"uint8\"}],\"name\":\"getAttachesto\",\"outputs\":[{\"name\":\"\",\"type\":\"int8[3][]\"}],\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"which\",\"type\":\"uint8\"},{\"name\":\"occupies\",\"type\":\"int8[3][8]\"}],\"name\":\"initOccupies\",\"outputs\":[],\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"which\",\"type\":\"uint8\"},{\"name\":\"attachesto\",\"type\":\"int8[3][]\"}],\"name\":\"initAttachesto\",\"outputs\":[],\"type\":\"function\"},{\"constant\":true,\"inputs\":[{\"name\":\"which\",\"type\":\"uint8\"}],\"name\":\"getOccupies\",\"outputs\":[{\"name\":\"\",\"type\":\"int8[3][8]\"}],\"type\":\"function\"}]\n","bytecode":"60606040526106a3806100126000396000f3606060405260e060020a60003504630878bc51811461003c5780631256c698146100f3578063197bcde7146101515780631bcf5758146101c2575b005b61029a60043560408051602081019091526000815260038260148110156100025790906009020160005060080180546040805160208381028201810190925282815292919060009084015b82821015610375576000848152602081206040805160608101918290529291850191600391908390855b825461010083900a900460000b8152602060019283018181049485019490930390920291018084116100b1579050505050505081526020019060010190610087565b60408051610100810190915261003a90600480359161032490602460086000835b828210156102f557604080516060818101909252908381028601906003908390839080828437820191505050505081526020019060010190610114565b604080516024803560048181013560208181028601810190965280855261003a958235959294604494019190819060009085015b8282101561031057604080516060818101909252908381028701906003908390839080828437820191505050505081526020019060010190610185565b610331600435610300604051908101604052806008905b6060604051908101604052806003905b60008152602001906001900390816101e9579050508152602001906001900390816101d957506003905082601481101561000257600902016000506040805161010081019091529060086000835b82821015610375576040805160608101918290529085840190600390826000855b825461010083900a900460000b815260206001928301818104948501949093039092029101808411610258579050505050505081526020019060010190610237565b60405180806020018281038252838181518152602001915080516000925b818410156102e457602084810284010151606080838184600060046018f15090500192600101926102b8565b925050509250505060405180910390f35b509294505050505060025460009060ff16156103935761038e565b509395505050505050600254600090610100900460ff16156104e25761038e565b6040516000826008835b818410156103655760208402830151606080838184600060046018f150905001926001019261033b565b9250505091505060405180910390f35b505050509050919050565b6002805460ff191660011790555b505050565b81600384601481101561000257506009850290810191600b91909101908261010082015b8281111561041457825182906001820190826060820160005b8382111561045157835183826101000a81548160ff021916908360f860020a90810204021790555092602001926001016020816000010492830192600103026103d0565b506104939291505b8082111561048f576000815560010161041c565b505061047e9291505b8082111561048f57805460ff19168155600101610439565b80156104305782816101000a81549060ff0219169055600101602081600001049283019260010302610451565b5050916020019190600101906103b7565b5090565b5060009050836020811015610002575090505b60208160ff1610156103805760008160208110156100025760208082045491066101000a900460ff1614156104da5761038e565b6001016104a6565b815160038460148110156100025760090201600050600801600050818154818355818115116105225760008381526020902061052291810190830161041c565b50505050816003600050846014811015610002578251600991909102600b0180548282556000828152602090819020929591830194500182156105c3579160200282015b828111156105c357825182906001820190826060820160005b838211156105dc57835183826101000a81548160ff021916908360f860020a908102040217905550926020019260010160208160000104928301926001030261057f565b5061061a92915061041c565b5050610609929150610439565b80156105cf5782816101000a81549060ff02191690556001016020816000010492830192600103026105dc565b505091602001919060010190610566565b5060019050808460208110156100025760208082049092019190066101000a81548160ff02191690830217905550600090505b60208160ff161015610687576001816020811015610002576020808204909201549190066101000a900460ff166000141561069b5761038e565b6002805461ff001916610100179055505050565b60010161064d56"}]
 
 
 */

