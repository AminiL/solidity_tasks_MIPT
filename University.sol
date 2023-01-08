// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;


contract University {
    struct Student{
        string name;
        uint age;
    }

    uint numGroups = 0;
    Student[] students;
    uint[] groups;

    constructor (uint _numGroups) {
        numGroups = _numGroups;
    }

    function addStudent(string memory name, uint age) public {
        students.push(Student(name, age));
        groups.push(uint(keccak256(abi.encodePacked(block.number, name, age))) % numGroups);
    }

    function getStudentName(uint num) public view returns(string memory) {
        return students[num].name;
    }

    function getStudentAge(uint num) public view returns(uint) {
        return students[num].age;
    }
}