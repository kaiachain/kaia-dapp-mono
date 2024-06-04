# SchoolSystemFactory and SchoolContract Explanation

## SchoolSystemFactory Contract

### Overview:
- The `SchoolSystemFactory` contract is responsible for deploying instances of the `SchoolSystem` contract.
- It keeps track of deployed `SchoolSystem` contracts by storing their addresses in the `deployedSchoolSystems` array.

### Functions:
1. **`createSchoolSystem`**: 
   - Function to deploy a new instance of the `SchoolSystem` contract.
   - Accepts parameters `name` and `symbol` for the name and symbol of the associated KIP17 token.
   - Emits an event `SchoolSystemDeployed` after deployment.
   
2. **`getDeployedSchoolSystemsCount`**:
   - View function to get the number of deployed `SchoolSystem` contracts.
   - Returns the length of the `deployedSchoolSystems` array.

## SchoolSystem Contract

### Overview:
- The `SchoolSystem` contract represents a system for managing courses, students, and lecturers in a school.
- It inherits from the `KIP17` contract, allowing it to act as a Klaytn-based non-fungible token (NFT).
- The contract also uses the `Ownable` contract, enabling ownership management functionalities.

### Storage Variables:
- `courseCount`, `lecturerCount`, and `studentCount`: Counters for tracking the number of courses, lecturers, and students.
- Various mappings for storing course details, lecturer and student tokens, and attendance information.

### Modifiers:
- `onlyAdmin`, `onlyLecturer`, and `onlyStudent`: Modifiers restricting access to certain functions based on roles.

### Constructor:
- Initializes the contract with the name and symbol of the associated KIP17 token.

### Functions:
1. **Management Functions**:
   - `employ_Lecturer`: Employ a new lecturer.
   - `admit_student`: Admit a new student.
   - `transferOwnership`: Transfer ownership of the contract.

2. **Course Management Functions**:
   - `createCourse`: Create a new course.
   - `registerForCourse`: Register a student for a course.

3. **Class Session Functions**:
   - `createClassSession`: Create a new class session for a course.
   - `markAttendance`: Mark attendance for a class session.

4. **Query Functions**:
   - `getSessionIdsForLecturer`: Get session IDs for a lecturer.
   - `getTotalRegisteredCourses`: Get the total number of registered courses for a student.
   - `calculateAttendancePercentage`: Calculate the attendance percentage for a student.

### Internal Functions:
- `courseNameExists`: Check if a course name already exists.
- `getCourseSessionIds`: Get session IDs for a specific course.

### Events:
- `StudentRegistered`: Fired when a student registers for a course.
- `CourseCreated`: Fired when a new course is created.
- `ClassSessionCreated`: Fired when a new class session is created.
- `AttendanceMarked`: Fired when attendance is marked for a class session.
