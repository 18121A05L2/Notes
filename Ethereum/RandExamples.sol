contract RandExamples {
    //---------------------
    struct Person {
        mapping(uint256 id => uint256 age) details;
    }

    mapping(string name => Person) people;

    function addPeople(string calldata _name, uint256 _id, uint256 _age) external returns (bool) {
        people[_name].details[_id] = _age;
        return true;
    }

    function readPeople(string calldata _name, uint256 _id) external view returns (uint256 age) {
        return people[_name].details[_id];
    }

    function deletePerson(string calldata _name) external {
        delete people[_name];
    }
    //--------------------
}
