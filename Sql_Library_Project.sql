drop database if exists library;
create database library;
use library;

create table borrower(
borrower_CardNo int auto_increment primary key,
borrower_BorrowerName varchar(100),
borrower_BorrowerAddress varchar(100),
borrower_BorrowerPhone varchar(50));

select * from borrower;

create table publisher(
publisher_PublisherName varchar(50) primary key,
publisher_PublisherAddress varchar(100),
publisher_PublisherPhone varchar(50));

select * from publisher;

create table books(
book_BookID int auto_increment primary key,
book_Title varchar(50),
book_PublisherName varchar(50),
foreign key(book_PublisherName) references publisher(publisher_PublisherName) on delete cascade);

ALTER TABLE books RENAME COLUMN ï»¿book_BookID TO book_BookID;
select * from books;

create table authors(
book_authors_AuthorID int auto_increment primary key,
book_authors_BookID int not null,
book_authors_AuthorName varchar(50),
foreign key(book_authors_BookID) references books(book_BookID) on delete cascade);

ALTER TABLE authors RENAME COLUMN ï»¿book_authors_BookID TO book_authors_BookID;
select * from authors;

create table library_branch(
library_branch_BranchID int auto_increment primary key,
library_branch_BranchName varchar(50),
library_branch_BranchAddress varchar(100));

select * from library_branch;

create table book_copies(
book_copies_CopiesID int auto_increment primary key,
book_copies_BookID int,
book_copies_BranchID int,
book_copies_No_Of_Copies int,
foreign key(book_copies_BookID) references books(book_BookID) on delete cascade,
foreign key(book_copies_BranchID) references library_branch(library_branch_BranchID) on delete cascade);

ALTER TABLE book_copies RENAME COLUMN ï»¿book_copies_BookID TO book_copies_BookID;
select * from book_copies;

create table book_loans(
book_loans_LoansID int auto_increment primary key,
book_loans_BookID int not null,
book_loans_BranchID int not null,
book_loans_CardNo int not null,
book_loans_DateOut date,
book_loans_DueDate date,
foreign key(book_loans_BookID) references books(book_BookID) on delete cascade,
foreign key(book_loans_BranchID) references library_branch(library_branch_BranchID) on delete cascade,
foreign key(book_loans_CardNo) references borrower(borrower_CardNo) on delete cascade);

ALTER TABLE book_loans RENAME COLUMN ï»¿book_loans_BookID TO book_loans_BookID;
select * from book_loans;

-- Task Questions:
#How many copies of the book titled "The Lost Tribe" are owned by the library branch whose name is "Sharpstown"?
select temp.book_copies_BookID,temp.book_copies_No_Of_Copies from(
select t1.book_copies_BookID,t1.book_copies_BranchID,t1.book_copies_No_Of_Copies from book_copies as t1 inner join books as t2 
on t1.book_copies_BookID=t2.book_BookID where t2.book_Title="The Lost Tribe") as temp
inner join library_branch on temp.book_copies_BranchID=library_branch.library_branch_BranchID
where library_branch.library_branch_BranchName="Sharpstown";

#How many copies of the book titled "The Lost Tribe" are owned by each library branch?
select temp.book_copies_No_Of_Copies,library_branch.library_branch_BranchName from(
select t1.book_copies_No_Of_Copies,t1.book_copies_BranchID from book_copies as t1 inner join books as t2 
on t1.book_copies_BookID=t2.book_BookID where t2.book_Title="The Lost Tribe") as temp
inner join library_branch on temp.book_copies_BranchID=library_branch.library_branch_BranchID;

#Retrieve the names of all borrowers who do not have any books checked out.
select t1.borrower_BorrowerName from borrower as t1 left join book_loans as t2
on t1.borrower_CardNo=t2.book_loans_CardNo where t2.book_loans_DateOut is null;

#For each book that is loaned out from the "Sharpstown" branch and whose DueDate is 2/3/18, retrieve the book title, the borrower's name, and the borrower's address. 
select t3.book_Title,t4.borrower_BorrowerName,t4.borrower_BorrowerAddress
from library_branch as t1 inner join book_loans as t2 on t1.library_branch_BranchID=t2.book_loans_BranchID 
inner join books as t3 on t3.book_BookID = t2.book_loans_BookID
inner join borrower as t4 on t4.borrower_CardNo = t2.book_loans_CardNo 
where t1.library_branch_BranchName ="Sharpstown" and t2.book_loans_DueDate="2/3/2018";

#For each library branch, retrieve the branch name and the total number of books loaned out from that branch.
select t1.library_branch_BranchName, count(t2.book_loans_BookID) as total_number_of_books
from library_branch as t1 inner join book_loans as t2
on t1.library_branch_BranchID=t2.book_loans_BranchID group by t1.library_branch_BranchName;

#Retrieve the names, addresses, and number of books checked out for all borrowers who have more than five books checked out.
select t1.borrower_BorrowerName,t1.borrower_BorrowerAddress,count(t2.book_loans_BookID) as number_of_books
from borrower as t1 inner join book_loans as t2 on t1.borrower_CardNo=t2.book_loans_CardNo
group by t1.borrower_BorrowerName,t1.borrower_BorrowerAddress having number_of_books > 5;

#For each book authored by "Stephen King", retrieve the title and the number of copies owned by the library branch whose name is "Central".
select t2.book_Title,t3.book_copies_No_Of_Copies from authors as t1 
inner join books as t2 on t1.book_authors_BookID=t2.book_BookID
inner join book_copies as t3 on t3.book_copies_BookID=t2.book_BookID
inner join library_branch as t4 on t3.book_copies_BranchID=t4.library_branch_BranchID
where t1.book_authors_AuthorName="Stephen King" and t4.library_branch_BranchName="Central";