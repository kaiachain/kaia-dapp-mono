// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.7;

import "@klaytn/contracts/KIP/token/KIP17/KIP17.sol";
import "@klaytn/contracts/utils/Counters.sol";
import "@klaytn/contracts/access/Ownable.sol";

contract SchoolSystem is KIP17, Ownable {
    using Counters for Counters.Counter;

    uint private courseCount;
    uint private lecturerCount;
    uint private studentCount;

// Mapping to store course names and their corresponding IDs
    mapping(string => uint) internal courseNameToId;
    mapping(address => uint) private lecturerTokens; // Track tokens for each lecturer
    mapping(address => uint) private studentTokens; // Track tokens for each student
    mapping(address => bool) private isLecturer;
    mapping(address => bool) private isStudent;
    mapping(uint => Course) public courses;
    mapping(uint => ClassSession) private classSessions;
    mapping(address => uint[]) public studentCourses; // Track courses registered by each student
    mapping(address => mapping(uint => uint)) private studentSessionAttendance; // Track student attendance for each session
    mapping(address => bool) private lecturerHasCourse;


// Event emitted when a student registers for a course
    event StudentRegistered(string courseName, address student);
    event CourseCreated(uint id, string name, address lecturer, uint capacity);
    event StudentRegistered(uint courseId, address student);
    event ClassSessionCreated(uint id, uint courseId, uint timestamp);
    event AttendanceMarked(uint sessionId, address student);
    
    struct Course {
        uint id;
        string name;
        address lecturer;
        uint capacity;
        uint enrolledStudents;
        uint sessionId;
        mapping(address => bool) students;
        string description;
    }
    
    struct ClassSession {
        uint id;
        uint courseId;
        uint timestamp;
        bool marked;
    }
    
    
    modifier onlyAdmin() {
        require(msg.sender == owner(), "Only admin can perform this action");
        _;
    }
    
    modifier onlyLecturer() {
        require(isLecturer[msg.sender], "Only lecturer can perform this action");
        _;
    }

     modifier onlyStudent() {
        require(isStudent[msg.sender], "Only student can perform this action");
        _;
    }
    
     constructor(string memory name, string memory symbol) KIP17(name, symbol) {}
    // Function to transfer ownership
  function transferOwnership(address newOwner) public  override {
    _transferOwnership(newOwner);
}
    function employ_Lecturer(address _lecturer, uint _amount) external onlyAdmin {
        require(!isLecturer[_lecturer], "Lecturer already exists");
        lecturerTokens[_lecturer] += _amount;
        isLecturer[_lecturer] = true;
        lecturerCount++;
    }
    function admit_student(address _student, uint _amount) external onlyAdmin {
        require(!isStudent[_student], "student already exists");
        studentTokens[_student] += _amount;
        isStudent[_student] = true;
        studentCount++;
    }
 

// Function to register for a course using the course name
    function registerForCourse(string memory _courseName) external onlyStudent {
    require(courseNameToId[_courseName] != 0, "Course not found");
    uint _courseId = courseNameToId[_courseName];
    
    Course storage course = courses[_courseId];
    require(course.enrolledStudents < course.capacity, "Course is full");
    require(!course.students[msg.sender], "Already registered");
    
    course.enrolledStudents++;
    course.students[msg.sender] = true;
    studentCourses[msg.sender].push(_courseId); // Update student's registered courses
    emit StudentRegistered(_courseName, msg.sender);
}

// Function to create a new course
function createCourse(string memory _name, uint _capacity, string memory course_desc) external onlyLecturer {
    require(lecturerTokens[msg.sender] > 0, "Insufficient tokens");
    require(!lecturerHasCourse[msg.sender], "Lecturer already has a course");

    // Check if the course with the same name already exists
    require(!courseNameExists(_name), "Course with this name already exists");

    courseCount++;
    uint _courseId = courseCount;
    Course storage course = courses[_courseId];
    course.name = _name;
    course.lecturer = msg.sender;
    course.capacity = _capacity;
    course.enrolledStudents = 0;
    course.sessionId = 0;
    course.description = course_desc;
    courseNameToId[_name] = _courseId; // Update course name to ID mapping
    lecturerHasCourse[msg.sender] = true; // Mark lecturer as having a course
    emit CourseCreated(_courseId, _name, msg.sender, _capacity);
}

function courseNameExists(string memory _name) internal view returns (bool) {
    return courseNameToId[_name] != 0;
}

    function getCoursesRegisteredByStudent(address _student) external view returns (uint[] memory) {
    return studentCourses[_student];
}

    
    function createClassSession(uint _courseId, uint _timestamp) external onlyLecturer {
        require(lecturerTokens[msg.sender] > 0, "Insufficient tokens");
        require(_courseId > 0 && _courseId <= courseCount, "Invalid course ID");
        
        uint sessionId = uint(keccak256(abi.encodePacked(block.timestamp, msg.sender, _courseId)));
        classSessions[sessionId] = ClassSession(sessionId, _courseId, _timestamp, false);
        emit ClassSessionCreated(sessionId, _courseId, _timestamp);
        _mint(msg.sender, sessionId);
        courses[_courseId].sessionId = sessionId;
    }
    
    function markAttendance(uint _sessionId) external onlyStudent {
        require(_sessionId > 0, "Invalid session ID");
        ClassSession storage session = classSessions[_sessionId];
        require(session.courseId > 0, "Session not found");
        require(!session.marked, "Attendance already marked");
        require(courses[session.courseId].students[msg.sender], "Student not enrolled in the course");

        studentSessionAttendance[msg.sender][_sessionId] = 1; // Mark attendance for student
        session.marked = true;
        emit AttendanceMarked(_sessionId, msg.sender);
    }
    
   function getSessionIdsForLecturer() external view onlyLecturer returns (uint[] memory) {
    uint[] memory sessionIds = new uint[](courseCount); // Initialize the array with the correct length
    uint counter = 0;
    for (uint i = 1; i <= courseCount; i++) {
        if (courses[i].lecturer == msg.sender && courses[i].sessionId != 0) {
            sessionIds[counter] = courses[i].sessionId;
            counter++;
        }
    }
    return sessionIds;
}


    function getTotalRegisteredCourses() external view returns (uint) {
        return studentCourses[msg.sender].length;
    }

    function calculateAttendancePercentage() external view  onlyStudent returns (uint) {
    uint totalSessionsAttended = 0;
    uint totalSessions = 0;
    for (uint i = 0; i < studentCourses[msg.sender].length; i++) {
        uint courseId = studentCourses[msg.sender][i];
        uint[] memory sessionIds = getCourseSessionIds(courseId);
        totalSessions += sessionIds.length;
        for (uint j = 0; j < sessionIds.length; j++) {
            if (studentSessionAttendance[msg.sender][sessionIds[j]] == 1) {
                totalSessionsAttended++;
            }
        }
    }
    if (totalSessions == 0) {
        return 0;
    } else {
        return (totalSessionsAttended * 100) / totalSessions;
    }
}

 function getAllCourseNames() external view returns (string[] memory) {
    string[] memory names = new string[](courseCount);

    for (uint i = 1; i <= courseCount; i++) {
        names[i - 1] = courses[i].name;
    }

    return names;
}


    function getCourseSessionIds(uint _courseId) internal view returns (uint[] memory) {
        uint[] memory sessionIds = new uint[](courseCount);
        uint counter = 0;
        for (uint i = 0; i < courseCount; i++) {
            if (courses[i].id == _courseId && courses[i].sessionId != 0) {
                sessionIds[counter] = courses[i].sessionId;
                counter++;
            }
        }
        return sessionIds;
    }
}
