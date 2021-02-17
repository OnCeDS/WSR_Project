// SPDX-License-Identifier: GPL-3.0

pragma solidity =0.8.1;

contract qwerty
{
    constructor() 
    {
        _createProperty(12, "TEST", address(0x5B38Da6a701c568545dCfcB03FcB875f56beddC4), false, 20, 30, true);
        _createProperty(13, "TEST1",address(0x17F6AD8Ef982297579C203069C1DbfFE4348c372), false, 40, 53, true);
        _createProperty(14, "TEST2", address(0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2), true, 15, 21, true);
        _createProperty(15, "TEST3", address(0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db), false, 35, 41, true);
        _createProperty(16, "TEST4", address(0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB), true, 15, 3, true);
        _createProperty(17, "TEST5", address(0x617F2E2fD72FD9D5503197092aC168c91465E7f2), true, 85, 203, true);
        _createProperty(18, "TEST6", address(0x5c6B0f7Bf3E7ce046039Bd8FABdfD3f9F5021678), false, 655, 243, true);
        _createProperty(19, "TEST7", address(0x03C6FcED478cBbC9a4FAB34eF9f40767739D1Ff7), true, 653, 223, true);
        _createProperty(20, "TEST8", address(0x1aE0EA34a72D944a8C7603FfB3eC30a6669E454C), false, 325, 213, true);
        _createProperty(21, "TEST9", address(0x0A098Eda01Ce92ff4A4CCb7A4fFFb5A43EBC70DC), false, 344, 223, true);
        
        default_address = payable(0x0000000000000000000000000000000000000000);
    }
    
    modifier isOwner(uint ID)
    {
        require(msg.sender == ownerToID[ID], " Access error! ");
        _;    
    }
    
    modifier AccessToCreate(uint ID)
    {
        require(msg.sender == propertys[ID].owner, "Ne tvoe!");
        _;
    }
    
    modifier AccessToAccept(uint ID)
    {
        require(msg.sender == presents[ID].to, "Ne tebe!");
        _;
    }

    struct Property
    {
        uint ID;            // - ID (0)
        string name;        // - собственник ("Name")
        address owner;       // - Адрес (0x..)
        bool deposite;      // - обременения (true / false)
        uint all_area;      // - Общая площадь (0)
        uint true_area;     // - Полезная площадь (0)
        bool active;        // - Активность (true / false)
    }
    
    struct Present
    {
        uint ID_Property;
        address _from;
        address to;
        bool finished;
    }
    
    struct Sale
    {
        uint ID_Property;
        uint price;
        //uint srok;
        bool finished;
    }
    
    struct Pledge
    {
        uint ID_Property;
        uint price;
        address froms;
        address to;
        //uint time;
        bool finished;
    }
    
    struct Rent 
    {
      uint ID_Property;
      uint price;
      address froms;
      address to;
      bool finished;
    }
    
    Sale[] sales;
    Rent [] rents;
    Pledge[] pledges;
    Present[] presents;
    Property[] propertys;
    
    address payable default_address;
    
    mapping(uint=>address) ownerToID;
    mapping(uint=>address[]) customers;
    mapping(uint=>address[]) hostages;
    mapping(uint=>address[]) renters;
    
    function _createRent(uint _ID_Property, uint _price, address _to) public
    {
        rents.push(Rent(_ID_Property, _price, msg.sender, _to, false));
    }
    
    function _viewRent(uint _ID_Property) public view returns (uint, address, address, bool)
    {
        Rent memory a = rents[_ID_Property];
        return (a.ID_Property, a.froms, a.to, a.finished);
        
    }
    
    function _rentProperty(uint _rentNumber) payable public
    {
        require(msg.value == rents[_rentNumber].price * 1 ether, " Money is low! ");
        require(rents[_rentNumber].finished != true, " Already completed! ");
        for(uint i = 0; i < renters[_rentNumber].length; i++)
        {
            require(renters[_rentNumber][i] != msg.sender, " Already available! ");
        }
        renters[_rentNumber].push(msg.sender);
    }
    
    function _acceptRent(uint _rentNumber, uint _ID) payable public
    {
        payable(propertys[rents[_rentNumber].ID_Property].owner).transfer(rents[_rentNumber].price * 1 ether);
        rents[_rentNumber].to = renters[_rentNumber][_ID];
        for(uint i = 0; i < renters[_rentNumber].length; i++)
        {
            if(renters[_rentNumber][i] != renters[_rentNumber][_ID])
            {
                payable(renters[_rentNumber][i]).transfer(rents[_rentNumber].price * 1 ether);
            }
        }
        
    }
    
    function _viewAllRents () public view returns(Rent[] memory)
    {
        return rents;
    }
    
     function _createProperty (uint _ID, string memory _name, address _link, bool _deposite, uint _all_area, uint _true_area, bool _active) public
    {
        propertys.push(Property(_ID ,_name, _link, _deposite, _all_area, _true_area, _active));
        //ownerToID[_ID] = _link;
    }
    
    function _acceptPleges(uint _ID_Property, uint _ID) payable public
    {
        payable(propertys[pledges[_ID_Property].ID_Property].owner).transfer(pledges[_ID_Property].price * 1 ether);
        pledges[_ID_Property].to = hostages[_ID_Property][_ID];
        for(uint i = 0; i < hostages[_ID_Property].length; i++)
        {
            if(hostages[_ID_Property][i] != hostages[_ID_Property][_ID])
            {
                payable(hostages[_ID_Property][i]).transfer(pledges[_ID_Property].price * 1 ether);
            }
        }
    }
    
    function _depositeProperty (uint _ID_Pledges) payable public
    {
        require(msg.value == pledges[_ID_Pledges].price * 1 ether, "Malo deneg!");
        require(pledges[_ID_Pledges].finished != true, "Uzhe prodali!");  
        for(uint i = 0; i < hostages[_ID_Pledges].length; i++)
        {
            require(hostages[_ID_Pledges][i] != msg.sender, "Uzhe est");
        }
        hostages[_ID_Pledges].push(msg.sender);
    }
    
    function _viewPledges(uint _ID_Property) public view returns (uint, address, address, bool)
    {
        Pledge memory a = pledges[_ID_Property];
        return (a.ID_Property, a.froms, a.to, a.finished);
    }
    

    
    function _returnMoney (uint _pledgesNumber) public payable
    {
        require (msg.value == pledges[_pledgesNumber].price * 1 ether, "Malo deneg!");
        payable(pledges[_pledgesNumber].to).transfer(pledges[_pledgesNumber].price * 1 ether);
        pledges[_pledgesNumber].finished = true;
    }
    
    function _notReturnMoney (uint _pledgesNumber) public payable
    {
        propertys[pledges[_pledgesNumber].ID_Property].owner = pledges[_pledgesNumber].to;
        pledges[_pledgesNumber].finished = true;
    }

    function _createPledges (uint _ID_Property, uint _price) public 
    {
        pledges.push(Pledge(_ID_Property, _price, msg.sender, default_address, false));
    }
    
    function _buyProperty(uint _saleNumber) payable public
    {
        require (msg.value == sales[_saleNumber].price * 1 ether, "Malo deneg!");
        require(sales[_saleNumber].finished != true, "Uzhe prodali!");  
        for(uint i = 0; i < customers[_saleNumber].length; i++)
        {
            require(customers[_saleNumber][i] != msg.sender, "Uzhe est");
        }
        customers[_saleNumber].push(msg.sender);
    }
    
    function _viewProperty (uint _id) public view returns (string memory, address, bool, uint, uint, bool)
    {
        Property memory a = propertys[_id];
        return (a.name, a.owner, a.deposite, a.all_area, a.true_area, a.active);
    }  
    
    function _viewAllPropertys() public view returns (Property[] memory)
    {
        return propertys;
    }

    function _createPresent (uint _id, address __from, address _to) public AccessToCreate(_id)
    {
        presents.push(Present(_id, __from, _to, false));
    }
    
    function _viewPresent () public view returns (Present[] memory)
    {
        Present[] memory tmp = new Present[](presents.length);
        uint j = 0;
        for(uint i = 0; i < presents.length; i++)
        {
            if(msg.sender == presents[i].to)
            {
                tmp[j] = presents[i];
                j++;
            }
        }
        return tmp; 
    }
    
    function _viewAllPresents() public view returns (Present[] memory)
    {
        return presents;
    }
    
    function _acceptPresent(uint _id) public AccessToAccept(_id)
    {
        propertys[presents[_id].ID_Property].owner = msg.sender;
        presents[_id].finished = true;
    }
    
    function _createSale(uint _id, uint _price) public AccessToCreate (_id)
    {
       // address payable[] memory customers;
        sales.push(Sale(_id, _price, false));
    }
    
    function _viewAllSales() public view returns (Sale[] memory)
    {
        return sales;
    }
    
    function _viewMoney() public view returns(uint)
    {
        return address(this).balance;   
    }
    
    function _transfer_Property (address _link, uint _ID) external isOwner(_ID)
    {
        //ownerToID[_ID] = _link;
        propertys[_ID].owner = _link;
    }
    
    function _acceptSale(uint _saleNumber, uint _buyer) payable public
    {
        payable(propertys[sales[_saleNumber].ID_Property].owner).transfer(sales[_saleNumber].price * 1 ether);
        for(uint i = 0; i < customers[_saleNumber].length; i++)
        {
            if(customers[_saleNumber][i] != customers[_saleNumber][_buyer])
            {
                payable(customers[_saleNumber][i]).transfer(sales[_saleNumber].price * 1 ether);
            }
        }
        propertys[sales[_saleNumber].ID_Property].owner = customers[_saleNumber][_buyer];
        sales[_saleNumber].finished = true;
    }
    
    function _viewCustomers(uint _saleNumber) public view returns(address[] memory)
    {
        return customers[_saleNumber];
    }
    
    function _viewHostager (uint _pledgesNumber) public view returns(address[] memory)
    {
        return hostages[_pledgesNumber];
    }
    
    function _getContractBalance() public view returns (uint)
    {
        return address(this).balance / (1 ether);
    }
    
    function _cancelSale(uint _saleNumber) public
    {
        for(uint i = 0; i < customers[_saleNumber].length; i++)
        {
            payable(customers[_saleNumber][i]).transfer(sales[_saleNumber].price * 1 ether);
        }
        sales[_saleNumber].finished = true;
    }
}
