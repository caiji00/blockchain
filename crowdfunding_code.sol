pragma solidity ^0.4.24;


//这是一个简单的众筹合约，可以用项目Id和项目名称来参与众筹。

contract CrowdFunding{
    
    //投资者是结构体
    struct Funder{
        address addr; //投资者地址
        uint amount;// 投资金额
    }
    
    //采用结构体来描述众筹产品
    struct Product{
        address addr; //成功转账地址
        string name;  //众筹产品的名字
        uint goal;    //众筹目标
        uint amount;  //实际众筹金额
        uint funderNum; //投资者人数
        
        mapping(uint => Funder) funders; 
        //映射类型，统计当前产品的投资者
    }
    
    //平台要统计的众筹产品数量
    uint public count;
    
    //主要记录平台的众筹产品,通过数字来映射
    mapping (uint => Product) public products;
    mapping (string => uint) public p_to_count;//把项目名字映射到项目id
    
    
    function candidate(address addr,string name, uint goal) returns (uint,string){
        // initialize
        products[count++] = Product(addr,name,goal, 0, 0);
        p_to_count[products[count-1].name] = count;     //形成一个名字映射到Id的数组
        return(count-1,products[count-1].name);
    }
    
    
    //实现对产品的众筹功能
    function vote(uint index) payable {
        Product c = products[index];
        
        //创建投资者，并存到产品众筹映射中，sender是众筹者，value是金额
        c.funders[c.funderNum++] = Funder({addr: msg.sender, amount: msg.value});
        c.amount += msg.value;
    }
    
    
    
    //重载vote方法，利用项目名来实现众筹
    function vote(string name) payable {
        uint index;
        index = p_to_count[name];//利用项目名来获得项目的编号index
        
        Product c = products[index];
        
        //创建投资者，并存到产品众筹映射中，sender是众筹者，value是金额
        c.funders[c.funderNum++] = Funder({addr: msg.sender, amount: msg.value});
        c.amount += msg.value;
    }
    
    
    //检查当前众筹产品是否成功
    function check(uint index) returns (bool){
        Product c = products[index];
        
        //未达目标金额，返回假
        if(c.amount < c.goal){
            return false;
        }
        
        //众筹成功，转账
        uint amount = c.amount;
        // incase send much more
        c.amount = 0;
        if(!c.addr.send(amount)){
            throw;
        }
        return true;
    }
    

    //重载check方法，用项目名来实现检查
    function check(string name) returns (bool){
        
        uint index;
        index = p_to_count[name];
        
        Product c = products[index];
        
        //未达目标金额，返回假
        if(c.amount < c.goal){
            return false;
        }
        
        //众筹成功，转账
        uint amount = c.amount;
        // incase send much more
        c.amount = 0;
        if(!c.addr.send(amount)){
            throw;
        }
        return true;
    }    



}
