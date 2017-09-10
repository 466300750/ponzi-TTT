pragma solidity ^0.4.11;


contract PonziTTT {

    // ================== Owner list ====================
    // list of owners
    address[256] owners;
    // required lessons
    uint256 required;
    // required deposit
    uint256 deposit;
    // limit block
    uint256 limitBlocks;
    // index on the list of owners to allow reverse lookup
    mapping(address => uint256) ownerIndex;
    // ================== Owner list ====================

    // ================== Trainee list ====================
    // balance of the list of trainees to allow refund value
    mapping(address => uint256) traineeBalances;
    // ================== Trainee list ====================
    mapping(address => uint256) traineeProgress;

    address[] traineeAddresses;

    // EVENTS

    // logged events:
    // Funds has arrived into the wallet (record how much).
    event Registration(address _from, uint256 _amount);
    event Confirmation(address _from, address _to, uint256 _lesson);
    // Funds has refund back (record how much).
    event Refund(address _from, address _to, uint256 _amount);
    event RefundFairly(address _from, address _to, uint256 _amount);

    modifier onlyOwner {
        require(isOwner(msg.sender));
        _;
    }

    function isOwner(address _addr) constant returns (bool) {
        return ownerIndex[_addr] > 0;
    }

    modifier onlyTrainee {
        require(isTrainee(msg.sender));
        _;
    }

    modifier notTrainee {
        require(!isTrainee(msg.sender));
        _;
    }

    function isTrainee(address _addr) constant returns (bool) {
        return traineeBalances[_addr] > 0;
    }

    function isFinished(address _addr) constant returns (bool) {
        return traineeProgress[_addr] >= required;
    }

    function PonziTTT(
        address[] _owners,
        uint256 _required,
        uint256 _deposit,
        uint256 _limitBlocks) {
        owners[1] = msg.sender;
        ownerIndex[msg.sender] = 1;
        required = _required;
        if (_deposit != 0) {
            deposit = _deposit;
        } else {
            deposit = 2;
        }
        limitBlocks = _limitBlocks;
        for (uint256 i = 0; i < _owners.length; ++i) {
            owners[2 + i] = _owners[i];
            ownerIndex[_owners[i]] = 2 + i;
        }
    }

    function() payable {
        register();
    }

    function register() payable notTrainee {
        require(msg.value == deposit * 1 ether);
        traineeAddresses.push(msg.sender);
        traineeBalances[msg.sender] = msg.value;
        Registration(msg.sender, msg.value);
    }

    function balanceOf(address _addr) constant returns (uint256) {
        return traineeBalances[_addr];
    }

    function progressOf(address _addr) constant returns (uint256) {
        return traineeProgress[_addr];
    }

    function confirmOnce(address _recipient) onlyOwner {
        require(isTrainee(_recipient));
        traineeProgress[_recipient] = traineeProgress[_recipient] + 1;
        Confirmation(msg.sender, _recipient, traineeProgress[_recipient]);
    }

    function checkContractBalance() constant returns (uint256) {
        return this.balance;
    }

    function refund(address _recipient) onlyOwner {
        require(isTrainee(_recipient));
        require(isFinished(_recipient));
        _recipient.transfer(traineeBalances[_recipient]);
        Refund(msg.sender, _recipient, traineeBalances[_recipient]);
        traineeBalances[_recipient] = 0;
    }

    function refundFairly() onlyOwner {
        require(block.number > limitBlocks);

        uint256 finishedCount;
        
        for (uint i = 0; i < traineeAddresses.length; i++) {
            if (isFinished(traineeAddresses[i])) {
                finishedCount++;
            }
            traineeBalances[traineeAddresses[i]] = 0;
        }

        if (finishedCount == 0) {
            return;
        }

        uint256 refundAmount = this.balance/finishedCount;

        for (uint j = 0; j < traineeAddresses.length; j++) {
            if (isFinished(traineeAddresses[j])) {
                traineeAddresses[j].transfer(refundAmount);
                // RefundFairly(msg.sender, traineeAddresses[j], refundAmount);
            }
        }
    
    }

    function destroy() onlyOwner {
        selfdestruct(msg.sender);
    }

    function destroyTransfer(address _recipient) onlyOwner {
        selfdestruct(_recipient);
    }
}
