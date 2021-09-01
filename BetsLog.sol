pragma solidity ^0.8.0;
// SPDX-License-Identifier: mosaaaaaaaaaaaaaaaaaaa

/**
 * @title LinkedList
 * @dev Data structure
 * @author Alberto Cuesta Cañada
 */


contract BetsLog {

    event ObjectCreated(uint256 id, uint256 data, address addr);
    event ObjectsLinked(uint256 prev, uint256 next);
    event ObjectRemoved(uint256 id);
    event NewHead(uint256 id);
    event SumValue(uint256 hawhaw, string name);
    event RemovedHead(uint256 headID, uint256 add, uint256 data);

    struct Object{
        uint256 id;
        uint256 next;
        uint256 data;
        address addr;
        uint bet;
    }

    uint256 public head;
    uint256 public idCounter;
    uint256 public total_bets;
    mapping (uint256 => Object) public objects;

    /**
     * @dev Creates an empty list.
     */
    constructor() {
        head = 0;
        idCounter = 1;
        total_bets = 0;
    }

    /**
     * @dev Retrieves the Object denoted by `_id`.
     */
    function get(uint256 _id)
        public
        virtual
        view
        returns (uint256, uint256, uint256, address)
    {
        Object memory object = objects[_id];
        return (object.id, object.next, object.data, object.addr);
    }


    function destroyAll() public{
        Object memory curr = objects[head];
        uint256 number_it = idCounter;
        while (number_it > 1) {
            number_it -= 1;
            curr = objects[curr.next];
            remove(curr.id);
        }
        idCounter = 1;
    }

    /**
     * returm two arrays containing the addresses and the bets devided by the sum_guess_right
     **/
    function redeemBets(uint256 all_sum) public returns (uint256[] memory, address[] memory){

        address[] memory addresses = new address[](idCounter-1);
        uint256[] memory values = new uint256[](idCounter-1);
        Object memory curr = objects[head];

        for(uint i=idCounter; i > 1 ; i--){
            addresses[idCounter-i] = curr.addr;
            values[idCounter-i] = ((curr.data)*(all_sum))/(total_bets);
            curr = objects[curr.next];
        }

        destroyAll();
        return (values, addresses);
    }

    /**
     * @dev Return the id of the first Object matching `_data` in the data field.
     */
    function findDataForAddress(address addr)
        public
        view
        returns (uint256)
    {
        uint256 sum = 0;
        Object memory curr = objects[head];
        uint256 number_it = idCounter;
        while (number_it > 1) {
            number_it -= 1;
            if(curr.addr == addr) {
                sum += curr.data;
            }
            curr = objects[curr.next];
        }
        return sum;
    }

     /**
     * @dev Given an Object, denoted by `_id`, returns the id of the Object that points to it, or 0 if `_id` refers to the Head.
     */
    function findPrevId(uint256 _id)
        public
        view
        returns (uint256)
    {
        if (_id == head) return 0;
        Object memory prevObject = objects[head];
        while (prevObject.next != _id) {
            prevObject = objects[prevObject.next];
        }
        return prevObject.id;
    }

     /**
     * @dev Returns the id for the Tail.
     */
    function findTailId()
        public
        view
        returns (uint256)
    {
        Object memory oldTailObject = objects[head];
        while (oldTailObject.next != 0) {
            oldTailObject = objects[oldTailObject.next];
        }
        return oldTailObject.id;
    }

    /**
     * @dev Insert a new Object as the new Head with `_data` in the data field.
     */
    function addHead(uint256 _data, address _addr, uint _bet)
        public
    {
        uint256 objectId = _createObject(_data, _addr, _bet);
        _link(objectId, head);
        _setHead(objectId);
        total_bets += _data;
        emit NewHead(objectId); //ADDED
    }

    /**
     * @dev Insert a new Object as the new Tail with `_data` in the data field.
     */
    function addTail(uint256 _data, address _addr, uint _bet) // NOTE THAT IT IS BETTER TO USED ADD TAIL FOR EFFICIENCY DURING DELETION
        public
    {
        if (head == 0) {
            addHead(_data, _addr, _bet);
        }
        else {
            uint256 oldTailId = findTailId();
            uint256 newTailId = _createObject(_data, _addr, _bet);
            _link(oldTailId, newTailId);
        }
    }

    /**
     * @dev Remove the Object denoted by `_id` from the List.
     */
    function remove(uint256 _id)
        public
    {
        Object memory removeObject = objects[_id];
        if (head == _id) {
            _setHead(removeObject.next);
        }
        else {
            uint256 prevObjectId = findPrevId(_id);
            _link(prevObjectId, removeObject.next);
        }
        delete objects[removeObject.id];
        emit ObjectRemoved(_id);
    }

    /**
     * @dev Internal function to update the Head pointer.
     */
    function _setHead(uint256 _id)
        internal
    {
        head = _id;
        emit NewHead(_id);
    }

    /**
     * @dev Internal function to create an unlinked Object.
     */
    function _createObject(uint256 _data, address _addr, uint _bet)
        internal
        returns (uint256)
    {
        uint256 newId = idCounter;
        idCounter += 1;
        Object memory object = Object(newId, 0, _data, _addr, _bet);
        objects[object.id] = object;
        emit ObjectCreated(
            object.id,
            object.data,
            object.addr
        );
        return object.id;
    }

    /**
     * @dev Internal function to link an Object to another.
     */
    function _link(uint256 _prevId, uint256 _nextId)
        internal
    {
        objects[_prevId].next = _nextId;
        emit ObjectsLinked(_prevId, _nextId);
    }


}
