const {
  time,
  loadFixture,
} = require("@nomicfoundation/hardhat-toolbox/network-helpers");
const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
const { expect } = require("chai");

describe("SchoolSystem", function () {
  it("should deploy the SchoolSystem contract and interact with it", async function () {
    // Deploy the SchoolSystem contract
    const SchoolSystem = await ethers.getContractFactory("SchoolSystem");
    const schoolSystem = await SchoolSystem.deploy("School System", "SCH");
    await schoolSystem.deployed();

    // Interact with the deployed contract
    const [owner, lecturer, student] = await ethers.getSigners();

    // Employ a lecturer
    await schoolSystem.employ_Lecturer(lecturer.address, 100);

    // Admit a student
    await schoolSystem.admit_student(student.address, 100);

    // Create a course
    const courseName = "Math";
    await schoolSystem.createCourse(courseName, 50);

    // Get all course names
    const courses = await schoolSystem.getAllCourseNames();

    // Verify the behavior
    expect(courses).to.deep.include(courseName);
  });
});
