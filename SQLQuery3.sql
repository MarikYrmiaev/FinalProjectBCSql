CREATE DATABASE BChef
go
 use BChef
 go
--DROP TABLE TBUsers
CREATE TABLE TBUsers(
	[UserID] [int] IDENTITY(1,1) NOT NULL PRIMARY KEY,
	[FirstName] [nvarchar](30) NULL,
	[LastName] [nvarchar](30) NULL,
	[Email] [nvarchar](50) NOT NULL,
	[Password] BINARY(64) NOT NULL,
	[Salt] UNIQUEIDENTIFIER,
	[PictureUri] nvarchar(max) NOT NULL,
	[Gender] char (1) NOT NULL
	)
GO
/*
DROP TABLE [dbo].[TBUsers]
GO
*/

CREATE TABLE Chat(
Chat_ID [int] IDENTITY(1,1) NOT NULL PRIMARY KEY,
UserID_1 int FOREIGN KEY REFERENCES TBUsers([UserID]) NOT NULL,
UserID_2 int FOREIGN KEY REFERENCES TBUsers([UserID]) NOT NULL
) 
GO

---DROP TABLE SaveTextChat
CREATE TABLE SaveTextChat
(
Chat_ID int FOREIGN KEY REFERENCES Chat([Chat_ID]) NOT NULL,
TextMassege [ntext] ,
UserID int FOREIGN KEY REFERENCES TBUsers([UserID]) NOT NULL,
TimeSend time
)
GO

CREATE TABLE TBResetPasswordRequests(
	[ID] uniqueidentifier PRIMARY KEY,
	[UserID] [int] FOREIGN KEY REFERENCES TBUsers([UserID]),
	[ResetRequesteDateTime] datetime
	)
GO
/*
DROP TABLE [dbo].[TBResetPasswordRequests]
GO
*/

CREATE TABLE TBRecipePicture(
	[Recipe_Id] [int] FOREIGN key REFERENCES TBUserRecipes([Recipe_Id]) NOT NULL ,
	[PictureUri] nvarchar(max)  NULL,
	[PictureName] nvarchar(100)  NULL,
	)
GO
SELECT * FROM TBRecipePicture
GO
/*
DROP TABLE [dbo].[TBRecipePicture]
GO
*/

CREATE TABLE TBPreparation(
	[Preparation_Code] [int] IDENTITY(1,1) NOT NULL PRIMARY KEY ,
	[Preparation_Name] [nvarchar] (20) not null	
	)
GO
/*
DROP TABLE [dbo].[TBPreparation]
GO
*/

CREATE TABLE TBSpices(
	[Spices_Code] [int] IDENTITY(1,1) NOT NULL PRIMARY KEY ,
	[Spices_Name] [nvarchar] (20) not null	
	)
GO
select * from TBIngredients
go
/*
DROP TABLE [dbo].[TBSpices]
GO
*/

CREATE TABLE TBIngredients (
	[Ingredients_Code] [int] IDENTITY(1,1) NOT NULL PRIMARY KEY ,
	[Ingredients_Name] [nvarchar] (20) not null	
	)
GO

/*
DROP TABLE [dbo].[TBIngredients]
GO
*/

--DROP TABLE TBUserRecipes
CREATE TABLE TBUserRecipes(
    [Recipe_Id] [int] IDENTITY(1,1) NOT NULL PRIMARY KEY,
	[UserID] [int] FOREIGN KEY REFERENCES TBUsers([UserID]) NOT NULL ,
	[RecipeName] [nvarchar] (30) not null,
	[RecipePictureUri] nvarchar(max) NULL,
	[Preparation_Code] [int] FOREIGN KEY REFERENCES TBPreparation([Preparation_Code]) NOT NULL ,
    [Note] [ntext] 
	)
GO

/*
DROP TABLE TBUserRecipes
GO
*/
--DROP TABLE TBRecipeDetails
CREATE TABLE TBRecipeDetails(
    numberID int IDENTITY (1,1) PRIMARY KEY,
    [Recipe_Id] [int] FOREIGN key REFERENCES TBUserRecipes([Recipe_Id]) NOT NULL,
    [Spices_Code] [int] FOREIGN KEY REFERENCES TBSpices([Spices_Code])  NULL,
	[Ingredients_Code] [int] FOREIGN KEY REFERENCES TBIngredients([Ingredients_Code]) NULL,
	)
GO
/*
DROP TABLE [dbo].[TBRecipeDetails]
GO
*/
CREATE TABLE TBAdministrator(
	[AdminID] int IDENTITY(1,1) NOT NULL PRIMARY KEY,
	[IdentityID] nvarchar(9) NOT NULL,
	[Email] nvarchar(50) NOT NULL,
	[name] nvarchar(30) NOT NULL,
	[password] BINARY(64) NOT NULL,
	[Salt] UNIQUEIDENTIFIER,
	[PictureUri] nvarchar(max)  NULL,
	)
GO
DECLARE @salt UNIQUEIDENTIFIER=NEWID()
INSERT INTO TBAdministrator (IdentityID,Email,name,password,salt)
VALUES ('GadiMarik','BChef@gmail.com','Admin',HASHBYTES('SHA2_512','1q2w3e4'+CAST(@salt AS NVARCHAR(36))),@salt)
GO
SELECT * FROM TBAdministrator
GO

/*
DROP TABLE [dbo].[TBAdministrator]
GO
*/

CREATE VIEW [dbo].[IngrrdientsView]
AS
SELECT        dbo.TBRecipeDetails.Recipe_Id, dbo.TBIngredients.Ingredients_Name, dbo.TBRecipeDetails.Ingredients_Code
FROM            dbo.TBIngredients INNER JOIN
                         dbo.TBRecipeDetails ON dbo.TBIngredients.Ingredients_Code = dbo.TBRecipeDetails.Ingredients_Code
GO


CREATE VIEW [dbo].[SpicesView]
AS
SELECT        dbo.TBRecipeDetails.Recipe_Id, dbo.TBSpices.Spices_Name, dbo.TBRecipeDetails.Spices_Code
FROM            dbo.TBRecipeDetails INNER JOIN
                         dbo.TBSpices ON dbo.TBRecipeDetails.Spices_Code = dbo.TBSpices.Spices_Code
GO

------------------------------------------- Procedures -------------------------------------------

----------------------------------------
----------- User controller -------------
----------------------------------------

------------SP GetUsers------------
--drop proc [dbo].[GetUsers]
Create PROC GetUsers
AS
SELECT * FROM TBUsers
go
EXEC GetUsers
GO

------------SP Register------------
-- הרשמה    --
--DROP PROC regisrerNewAccount
CREATE proc regisrerNewAccount
    @FirstName nvarchar(50),
	@LastName nvarchar(50),
	@Email nvarchar(50),
	@Password nvarchar(50),
	@PictureUri nvarchar(max),
	@Gender char (1),
	@UserId int output
As
	DECLARE @salt UNIQUEIDENTIFIER=NEWID() -- יצירת ID אוטומטי --
	IF not exists(SELECT Email FROM TBUsers WHERE Email = @Email) -- תנאי כאשר הוא ריק הוא יצור חדש--
		BEGIN
			-- הנתונים ושמירה  --
			INSERT INTO TBUsers(FirstName,LastName,Email,Password,Salt,PictureUri,Gender)
			-- שמירת הנתונים והצגתם + הסתרת הסיסמה בעזרת HASHBYTES --
			VALUES(@FirstName,@LastName,@Email,HASHBYTES('SHA2_512',@Password+CAST(@salt AS NVARCHAR(36))),@salt,@PictureUri,@Gender)
	  	    set @UserId = @@IDENTITY
		End
	Else
		Begin
			set @UserId = -1
		End
Go
Declare @id int
EXEC regisrerNewAccount 'NIV','OHAYON','NIV@GMAIL.COM','1Q2W3E4','FFDGHFFDSSRW','m',@id output
go


Declare @id int
Exec regisrerNewAccount 'shalom','griman','tal@gmail.com','1q2w3e4','//proj5.ruppin-tech.co.il/uploads/userProfile/shsh.jpg','M',@id out
Select @id as id
Go


------------SP Login------------
ALTER PROC Login (
	@Email nvarchar(50),
	@Password nvarchar(50)
	)
AS
	BEGIN
	DECLARE @UserID int
	IF EXISTS (SELECT TOP 1 UserID FROM TBUsers WHERE Email = @Email)
		BEGIN
		SET @UserID = (SELECT UserID FROM TBUsers WHERE Email = @Email AND Password =HASHBYTES('SHA2_512',@Password+CAST(Salt AS NVARCHAR(36))))
		IF(@UserID IS NOT NULL)
			SELECT *,  1 as 'UserType' FROM TBUsers
			WHERE UserID = @UserID
		END
	ELSE if exists (select top 1 AdminID from TBAdministrator WHERE Email = @Email)
	begin 
			SET @UserID = (SELECT AdminID FROM TBAdministrator WHERE Email = @Email AND Password =HASHBYTES('SHA2_512',@Password+CAST(Salt AS NVARCHAR(36))))
			IF(@UserID IS NULL)
				SELECT 0 AS UserID
			ELSE
				SELECT   name as FirstName, name as LastName, PictureUri, AdminID AS UserID ,Email, 2 as 'UserType', 'M' as Gender FROM TBAdministrator WHERE AdminID = @UserID
	end
	else
		SELECT -1 AS UserID
	END
GO
exec Login 'Sb@walla.com' ,'1q2w3e4'
go
exec Login 'BChef@gmail.com','1q2w3e4'
go
------------SP ResetPasswordRequest------------
-- שינוי סיסמה --
CREATE PROC ResetPasswordRequest (
	@Email nvarchar(50)
	)
AS
	BEGIN
		DECLARE @UserID int

		SELECT @UserID = UserID FROM TBUsers WHERE @Email = Email
		
		IF(@UserID IS NOT NULL) -- עם המתשמש קיים היכנס --
			BEGIN 
				-- שמירת סיסמה חדשה --
				DECLARE @GUID uniqueidentifier
				SET @GUID = NEWID()

				-- ביצוע שינוי סיסמה ושמירה בטבלה --
				INSERT INTO TBResetPasswordRequests(ID, UserID,ResetRequesteDateTime)
				VALUES(@GUID,@UserID,GETDATE())
				-- הצגת המשתמש על ידי Email --
				SELECT 1 AS ReturnCode , @GUID as UniqueID , @Email as Email
			END
		ELSE -- אם לא קיים --
			BEGIN
				-- יחזיר 0 ולא יהיה ניתן לשנות --
				SELECT 0 AS ReturnCode , NULL as UniqueID , NULL as Email
			END
	END

GO

exec ResetPasswordRequest 'morshervi@gmail.com'


------------SP ResetPassword------------
CREATE PROC ResetPassword (
	@uid uniqueidentifier,
	@NewPassword nvarchar(50)
	)
AS
	BEGIN 
		DECLARE @UserID int
		DECLARE @salt UNIQUEIDENTIFIER=NEWID()
		
		SELECT @UserID = UserID
		FROM TBResetPasswordRequests
		WHERE @uid = ID

		IF(@UserID IS NOT NULL)
			BEGIN
				--if uid is exists
				UPDATE TBUsers
				SET Password = HASHBYTES('SHA2_512',@NewPassword+CAST(@salt AS NVARCHAR(36))),Salt = @salt
				WHERE UserID = @UserID

				DELETE FROM TBResetPasswordRequests
				WHERE ID = @uid

				SELECT 1 AS ReturnCode
			END
		ELSE
			--if uid is not exists
			SELECT 0 AS ReturnCode
	END
GO

exec ResetPassword '8efc0390-e25f-492c-af92-4b3206bb4f34','1q2w3e4r'

----------------------------------------
----------- End User controller ---------
----------------------------------------

/*
 [Recipe_Id] [int] IDENTITY(1,1) NOT NULL PRIMARY KEY,
`	[UserID] [int] FOREIGN KEY REFERENCES TBUsers([UserID]) NOT NULL , 
	[Preparation_Code] [int] FOREIGN KEY REFERENCES TBPreparation([Preparation_Code]) NOT NULL ,
    [Note] [ntext] 
	)
*/

CREATE PROC GetTBUserRecipes
AS
SELECT * FROM TBUserRecipes
GO


------------
---DROP PROC InsertRecipe
ALTER proc InsertRecipe
@UserID int,
@RecipeName nvarchar (30),
@RecipePictureUri nvarchar(max),
@Preparation_Code int,
@Note ntext,
@Recipe_Id int output
as
INSERT INTO [dbo].[TBUserRecipes]
           ([UserID],
		    [RecipeName],
			[RecipePictureUri],
            [Preparation_Code],
            [Note])
     VALUES
           (@UserID, @RecipeName, @RecipePictureUri, @Preparation_Code,@Note)
	
set @Recipe_Id = CONVERT(int,SCOPE_IDENTITY())
GO

Declare @x int 
EXEC InsertRecipe 16,'Pasta','http://proj5.ruppin-tech.co.il/uploads/userProfile/shahar.jpg',1,'ymoo', @x output
print @x
go
INSERT INTO [dbo].[TBUserRecipes]
           ([UserID]
           ,[Preparation_Code]
           ,[Note])
     VALUES
           (7, 2,'hello world')
go
------------SP UpdateTBUserRecipes------------
--DROP PROC UpdateTBUserRecipes
CREATE PROC UpdateTBUserRecipes(
@Recipe_Id int,
@RecipeName nvarchar (30),
@RecipePictureUri nvarchar(max),
@Preparation_Code int,
@Note ntext,
@res int output
	)
	AS
		BEGIN
			IF EXISTS (SELECT * FROM TBUserRecipes WHERE Recipe_Id = @Recipe_Id)
				BEGIN
					UPDATE TBUserRecipes
					set RecipeName = @RecipeName,
                        RecipePictureUri = @RecipePictureUri,
					    Preparation_Code = @Preparation_Code,
						Note = @Note
					WHERE Recipe_Id = @Recipe_Id
					set @res = 1
				END
			ELSE
				BEGIN
					set @res = 0
				END
		END
GO

EXEC UpdateTBUserRecipes 1,3,"efewgwgrehetr",1
go
SELECT * FROM TBUserRecipes
GO
-----------------
--drop proc DeleteRecipe
CREATE proc DeleteRecipe
(
@Recipe_Id int )
as
	DELETE FROM TBRecipeDetails WHERE Recipe_Id = @Recipe_Id
	DELETE FROM TBUserRecipes WHERE Recipe_Id = @Recipe_Id
GO
exec DeleteRecipe 19
go



select * from RecipeView 
go
----------------------------------------
----------- End UserRecipes controller ---------
----------------------------------------

------------------
CREATE PROC GetTBRecipeDetails
AS
select * from [TBRecipeDetails]
go
---------InsertTBRecipeDetails
CREATE proc InsertTBRecipeDetails
(@Recipe_Id int ,
@Spices_Code int,
@Ingredients_Code INT)
as
if(@Spices_Code = 0)
begin
	INSERT INTO [dbo].[TBRecipeDetails](Recipe_Id,Spices_Code, Ingredients_Code)
		VALUES (@Recipe_Id,NULL,@Ingredients_Code)
end
else if(@Ingredients_Code = 0)
begin
	INSERT INTO [dbo].[TBRecipeDetails](Recipe_Id,Spices_Code, Ingredients_Code)
		VALUES (@Recipe_Id, @Spices_Code,NULL)
end

	

GO
INSERT INTO [dbo].[TBRecipeDetails]
           (Recipe_Id
           ,Spices_Code
           ,Ingredients_Code)
     VALUES
           (2 , 1,1)
go
EXEC InsertTBRecipeDetails 1,1,1
go


------------SP UpdateTBRecipeDetails------------
alter PROC UpdateTBRecipeDetails
(@Recipe_Id int ,
@Spices_Code int,
@Ingredients_Code int,
@res int output)
	AS
		BEGIN
			IF EXISTS (SELECT * FROM TBRecipeDetails WHERE Recipe_Id = @Recipe_Id)
				BEGIN
					UPDATE TBRecipeDetails
					set Spices_Code = @Spices_Code,
						Ingredients_Code = @Ingredients_Code
					WHERE Recipe_Id = @Recipe_Id
					set @res = 1
				END
			ELSE
				BEGIN
					set @res = 0
				END
		END
GO

EXEC UpdateTBRecipeDetails 20,2,1
go

SELECT * FROM TBRecipeDetails
GO
-----------------------------
----DROP Proc DeleteRecipeDetails
create Proc DeleteRecipeDetails
(
@Recipe_Id int )
as
	DELETE FROM TBRecipeDetails WHERE Recipe_Id = @Recipe_Id

GO

exec DeleteRecipeDetails 5
go
SELECT * FROM TBRecipeDetails
GO
----DROP PROC GetTBRecipePicture
CREATE PROC GetTBRecipePicture
AS
SELECT * FROM TBRecipePicture
GO
------------SP InsertPictureToTBRecipePicture-----------
-----DROP PROC InsertPictureToTBRecipePicture
ALTER PROC InsertPictureToTBRecipePicture(
	@Recipe_Id int,
	
	@PictureUri nvarchar (max)
	
)
AS
	BEGIN
		INSERT INTO TBRecipePicture(Recipe_Id,PictureUri)
				VALUES(@Recipe_Id,@PictureUri)

		SELECT * FROM TBRecipePicture
		WHERE @Recipe_Id = Recipe_Id
	END
GO
EXEC InsertPictureToTBRecipePicture 67,'http://proj5.ruppin-tech.co.il/uploads/ImageRecipe/45.jpg'
GO
------------SP UpdatePictureInTBRecipePicture------------
----DROP PROC UpdatePictureInTBRecipePicture
CREATE PROC UpdatePictureInTBRecipePicture (
	@Recipe_Id int,

	@PictureUri nvarchar(max)
 )
AS
	BEGIN
		UPDATE TBRecipePicture
		SET PictureUri = @PictureUri
		WHERE Recipe_Id = @Recipe_Id 

		SELECT * FROM TBRecipePicture
		WHERE Recipe_Id = @Recipe_Id 
	END
GO


------------SP DeletPictureFromTBRecipePicture------------
-----DROP PROC DeletPictureFromTBRecipePictur
CREATE PROC DeletPictureFromTBRecipePicture(
   @Recipe_Id int
) 
AS 
  BEGIN
	DECLARE @Row int
	IF EXISTS (SELECT * FROM TBRecipePicture WHERE Recipe_Id = @Recipe_Id )
		BEGIN
		DELETE	FROM TBRecipePicture WHERE   Recipe_Id = @Recipe_Id
		SELECT 1 AS Result
		END
	ELSE
		BEGIN
		SELECT 0 AS Result
		END
	
	----
  END
GO

exec DeletPictureFromTBRecipePicture 9,9
----------------------------------------
---- End Picture To  Recipe Picture -----
----------------------------------------

CREATE PROC GetTBPreparation
AS
SELECT * FROM TBPreparation
GO
------------SP InsertPreparationToTBPreparation------------
CREATE PROC InsertPreparationToTBPreparation(
	@Preparation_Name nvarchar(20)
)
AS
	BEGIN
		DECLARE @Preparatio_Code INT 
		INSERT INTO TBPreparation(Preparation_Name)
		VALUES(@Preparation_Name)
		set @Preparatio_Code = CONVERT(int,SCOPE_IDENTITY())
		SELECT * FROM TBPreparation
		WHERE Preparation_Code = @Preparatio_Code
		 
	END
GO
EXEC InsertPreparationToTBPreparation 'Pan'
GO

------------SP UpdatePreparationInTBPreparation------------
CREATE PROC UpdatePreparationInTBPreparation (
	@Preparation_Code int,

	@Preparation_Name nvarchar(20)
 )
AS
	BEGIN
		UPDATE TBPreparation
		SET Preparation_Name = @Preparation_Name
		WHERE Preparation_Code = @Preparation_Code 

		SELECT * FROM TBPreparation
		WHERE Preparation_Code = @Preparation_Code 
	END
GO


------------SP DeletPreparationFromTBPreparation------------
CREATE PROC DeletPreparationFromTBPreparation(
   @Preparation_Code int
) 
AS 
  BEGIN
	DECLARE @Row int
	IF EXISTS (SELECT * FROM TBPreparation WHERE Preparation_Code = @Preparation_Code )
		BEGIN
		DELETE	FROM TBPreparation WHERE   Preparation_Code = @Preparation_Code
		SELECT 1 AS Result
		END
	ELSE
		BEGIN
		SELECT 0 AS Result
		END
	
	----
  END
GO

exec DeletPreparationFromTBPreparation 1
go
----------------------------------------
---- End Preparation To Preparation controller -----
----------------------------------------
CREATE PROC GetTBSpices
AS
SELECT * FROM TBSpices
GO
------------SP InsertSpicesToTBSpices------------
create PROC InsertSpicesToTBSpices(
	@Spices_Name nvarchar(20)
)
AS
	BEGIN
	DECLARE @Spices_Code INT 
		INSERT INTO TBSpices(Spices_Name)
				VALUES(@Spices_Name)
		set @Spices_Code = CONVERT(int,SCOPE_IDENTITY())
		SELECT * FROM TBSpices
		WHERE Spices_Code = @Spices_Code
	END
GO

exec InsertSpicesToTBSpices  'Suger'
GO

------------SP UpdateSpicesInTBSpicesn------------
CREATE PROC UpdateSpicesInTBSpicesn (
	@Spices_Code int,

	@Spices_Name nvarchar(20)
 )
AS
	BEGIN
		UPDATE TBSpices
		SET Spices_Name = @Spices_Name
		WHERE Spices_Code = @Spices_Code 

		SELECT * FROM TBSpices
		WHERE Spices_Code = @Spices_Code 
	END
GO


------------SP DeletSpicesFromTBSpices------------
CREATE PROC DeletSpicesFromTBSpices(
   @Spices_Code int
) 
AS 
  BEGIN
	DECLARE @Row int
	IF EXISTS (SELECT * FROM TBSpices WHERE Spices_Code = @Spices_Code )
		BEGIN
		DELETE	FROM TBSpices WHERE   Spices_Code = @Spices_Code
		SELECT 1 AS Result
		END
	ELSE
		BEGIN
		SELECT 0 AS Result
		END
	
	----
  END
GO

exec DeletSpicesFromTBSpices 9
go
----------------------------------------
---- End Spices To Spices controller -----
----------------------------------------
CREATE PROC GetTBIngredients
AS
SELECT * FROM TBIngredients
GO
------------SP InsertIngredientsToTBIngredients------------
create PROC InsertIngredientsToTBIngredients(
	
	
	@Ingredients_Name nvarchar(20)
)
AS
	BEGIN
	DECLARE @Ingredients_Code INT 
		INSERT INTO TBIngredients(Ingredients_Name)
				VALUES(@Ingredients_Name)
				set @Ingredients_Code = CONVERT(int,SCOPE_IDENTITY())
		SELECT * FROM TBIngredients
		WHERE Ingredients_Code = @Ingredients_Code 
	END
GO
EXEC InsertIngredientsToTBIngredients "Pasta"
go
------------SP UpdateIngredientsInTBIngredients------------
CREATE PROC UpdateIngredientsInTBIngredients (
	@Ingredients_Code int,

	@Ingredients_Name nvarchar(20)
 )
AS
	BEGIN
		UPDATE TBIngredients
		SET Ingredients_Name = @Ingredients_Name
		WHERE Ingredients_Code = @Ingredients_Code 

		SELECT * FROM TBIngredients
		WHERE Ingredients_Code = @Ingredients_Code 
	END
GO


------------SP DeletIngredientsFromTBIngredients------------
create PROC DeletIngredientsFromTBIngredients(
   @Ingredients_Code int
) 
AS 
  BEGIN
	DECLARE @Row int
	IF EXISTS (SELECT * FROM TBIngredients WHERE Ingredients_Code = @Ingredients_Code )
		BEGIN
		DELETE	FROM TBIngredients WHERE   Ingredients_Code = @Ingredients_Code
		SELECT 1 AS Result
		END
	ELSE
		BEGIN
		SELECT 0 AS Result
		END
	
	----
  END
GO

exec DeletIngredientsFromTBIngredients 1
go
----------------------------------------
---- End Ingredients To TBIngredients controller -----
----------------------------------------

---------------------------------- Edit Profile ---------------------------
create proc EditProfile
    @UserID int,
    @FirstName nvarchar(50),
	@LastName nvarchar(50),
	@PictureUri nvarchar(max)
	
	
	AS
	BEGIN
			-- הנתונים ושמירה  --
		Update TBUsers
		set FirstName = @FirstName,LastName=@LastName,PictureUri=@PictureUri
		WHERE UserID = @UserID

		SELECT * FROM TBUsers
		WHERE UserID = @UserID
	END
Go
SELECT * FROM TBUsers
go

EXEC EditProfile 6,"gadi","Kupersmit","/static/media/ProfileImage.fbb387d2.png"
go
----------------------------------------------------------------------
----------------------------------------------------------------------
----------------------------------------------------------------------

ALTER view RecipeView
AS

SELECT        dbo.TBUsers.UserID, dbo.TBUsers.FirstName, dbo.TBUsers.LastName, dbo.TBUsers.PictureUri, dbo.TBUserRecipes.Recipe_Id, dbo.TBUserRecipes.RecipeName, dbo.TBUserRecipes.RecipePictureUri, 
                         dbo.TBUserRecipes.Preparation_Code, dbo.TBUserRecipes.Note, dbo.TBRecipeDetails.Spices_Code, dbo.TBRecipeDetails.Ingredients_Code, dbo.TBPreparation.Preparation_Name
FROM            dbo.TBPreparation INNER JOIN
                         dbo.TBUserRecipes ON dbo.TBPreparation.Preparation_Code = dbo.TBUserRecipes.Preparation_Code INNER JOIN
                         dbo.TBRecipeDetails ON dbo.TBUserRecipes.Recipe_Id = dbo.TBRecipeDetails.Recipe_Id INNER JOIN
                         dbo.TBUsers ON dbo.TBUserRecipes.UserID = dbo.TBUsers.UserID
go

/*
				

						 SELECT        dbo.TBUsers.UserID, dbo.TBUsers.FirstName, dbo.TBUsers.LastName, dbo.TBUsers.PictureUri, dbo.TBUserRecipes.Recipe_Id, dbo.TBUserRecipes.RecipeName, dbo.TBUserRecipes.Preparation_Code, 
                         dbo.TBUserRecipes.Note, dbo.TBRecipeDetails.Spices_Code, dbo.TBRecipeDetails.Ingredients_Code, dbo.TBPreparation.Preparation_Name, dbo.TBRecipePicture.PictureUri AS RcipePicture
FROM            dbo.TBPreparation INNER JOIN
                         dbo.TBUserRecipes ON dbo.TBPreparation.Preparation_Code = dbo.TBUserRecipes.Preparation_Code INNER JOIN
                         dbo.TBRecipeDetails ON dbo.TBUserRecipes.Recipe_Id = dbo.TBRecipeDetails.Recipe_Id INNER JOIN
                         dbo.TBRecipePicture ON dbo.TBUserRecipes.Recipe_Id = dbo.TBRecipePicture.Recipe_Id INNER JOIN
                         dbo.TBUsers ON dbo.TBUserRecipes.UserID = dbo.TBUsers.UserID
*/

						 
ALTER PROC GetAllRecipes
as 
select * from RecipeView 
go

ALTER PROC RecipeByUser
(@UserID int)
as 
select * from RecipeView Where UserID=@UserID
go

exec RecipeByUser 16
go

ALTER PROC RecipeById
(@Recipe_Id int)
as 
select * from RecipeView Where Recipe_Id=@Recipe_Id
go

exec RecipeById 19
go

CREATE proc GetRecipePics
(@Recipe_Id INT )
as 
SELECT * FROM [dbo].[TBRecipePicture] WHERE Recipe_Id= @Recipe_Id
GO
EXEC GetRecipePics 2
GO

Create proc GetRecipeSpices
(@Recipe_Id INT )
as 
select * from [dbo].[SpicesView] WHERE Recipe_Id= @Recipe_Id
GO
EXEC GetRecipeSpices 2
GO

Create proc GetRecipeIng
(@Recipe_Id INT )
as 
select * from [dbo].[IngrrdientsView] WHERE Recipe_Id= @Recipe_Id
GO
EXEC GetRecipeIng 2
GO

----------------------------------- CHAT -------------------------------

--------------------------------
--------  SaveTextChat ---------
--------------------------------
CREATE PROC CreateChat
(
@UserID_1 int,
@UserID_2 int
)
AS
BEGIN TRANSACTION
IF EXISTS(SELECT Chat_ID FROM Chat WHERE UserID_1 = @UserID_1 AND UserID_2 = @UserID_2)
BEGIN
SELECT 0
END
ELSE BEGIN
INSERT Chat(UserID_1, UserID_2) 
VALUES (@UserID_1, @UserID_2)
END
IF @@ERROR<>0
BEGIN
	ROLLBACK TRANSACTION
	PRINT(@@ERROR)
	RETURN
END
COMMIT TRANSACTION
GO

EXEC CreateChat 2,4
GO
--- DROP PROC TextMessege
CREATE PROC SandMessege
(@Chat_ID int,
@TextMassege ntext,
@UserID int
)
as
INSERT INTO [dbo].[SaveTextChat]
           (Chat_ID,
           TextMassege,
		   UserID,
		   TimeSend)
     VALUES
           (@Chat_ID, @TextMassege,@UserID,GETDATE())
GO

EXEC SandMessege 1,"HELLO GADI", 4
GO



-----------------------------------
 -----------------Get Chat -----------
 ----------------------------------
CREATE PROC GetAllChatsByUserID
(
@UserID int
)
AS
BEGIN TRANSACTION
SELECT * FROM Chat WHERE UserID_1 = @UserID OR UserID_2 = @UserID
IF @@ERROR<>0
BEGIN
	ROLLBACK TRANSACTION
	PRINT(@@ERROR)
	RETURN
END
COMMIT TRANSACTION
GO

EXEC GetAllChatsByUserID 2
GO

-----------------------------------------
-- מחזיר את כל ההודעות בצאט לפי מזהה של צאט
CREATE PROC GetAllRepliesByChatID
(
@Chat_ID int
)
AS
BEGIN TRANSACTION
SELECT * FROM SaveTextChat WHERE Chat_ID = @Chat_ID
ORDER BY TimeSend
IF @@ERROR<>0
BEGIN
	ROLLBACK TRANSACTION
	PRINT(@@ERROR)
	RETURN
END
COMMIT TRANSACTION
GO

EXEC GetAllRepliesByChatID 1
GO
--------------------------
-- בודק אם קיים צאט כבר
CREATE PROC DoesChatExists
(
@Chat_ID int,
@UserID_1 int,
@UserID_2 int
)
AS
BEGIN TRANSACTION
SELECT Chat_ID FROM Chat WHERE Chat_ID = @Chat_ID AND (UserID_1 = @UserID_1 AND UserID_2 = @UserID_2)
IF @@ERROR<>0
BEGIN
	ROLLBACK TRANSACTION
	PRINT(@@ERROR)
	RETURN
END
COMMIT TRANSACTION
GO

EXEC DoesChatExists 1,2,4
GO

-- מחזיר את המזהה של הצאט לפי המשתתפים
CREATE PROC GetChatID
(
@UserID_1 int,
@UserID_2 int
)
AS
BEGIN TRANSACTION
IF EXISTS(SELECT Chat_ID FROM Chat WHERE UserID_1 = @UserID_1 AND UserID_2 = @UserID_2)
BEGIN
	SELECT Chat_ID FROM Chat WHERE UserID_1 = @UserID_1 AND UserID_2 = @UserID_2
END
ELSE BEGIN
	SELECT -1
END
IF @@ERROR<>0
BEGIN
	ROLLBACK TRANSACTION
	PRINT(@@ERROR)
	RETURN
END
COMMIT TRANSACTION
GO

EXEC GetChatID 2,4
GO