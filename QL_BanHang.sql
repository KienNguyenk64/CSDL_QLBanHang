CREATE DATABASE QL_BanHang
use QL_BanHang;

CREATE table KH (
    MAKH VARCHAR(10) not null primary KEY,
    HoTenKH NVARCHAR(30),
    SoCCCD VARCHAR(12),
    DC_LienHe NVARCHAR(20),
    Email VARCHAR(50)
);

CREATE table HH (
    MaHH VARCHAR(10) NOT null primary key,
    TenHH NVARCHAR(50),
    Giatri FLOAT,
    SoTienlan1 FLOAT,
    Sotiencaclantiep FLOAT,
    MaKH VARCHAR(10) REFERENCES KH(MaKH)
);

CREATE TABLE PT(
    SoPT VARCHAR(10) not null PRIMARY KEY,
    MaKH VARCHAR(10) REFERENCES KH(MaKH),
    MaHH VARCHAR(10) REFERENCES HH(MaHH),
    Ngaythang DATE,
    SoTientra FLOAT,
    LoaiPT VARCHAR(10) check(LoaiPT = 0 or LoaiPT = 1),
    GhiChu Ntext
);

INSERT INTO KH (MAKH, HoTenKH, SoCCCD, DC_LienHe, Email)
VALUES 
('KH001', N'Nguyễn Văn A', '123456789012', N'123 Đường ABC Quận 1', 'nguyenvana@example.com'),
('KH002', N'Phạm Thị B', '234567890123', N'456 Đường XYZ Quận 2', 'phamthib@example.com'),
('KH003', N'Lê Minh C', '345678901234', N'789 Đường MNO Quận 3', 'leminhc@example.com'),
('KH004', N'Trần Hoài D', '456789012345', N'101 Đường PQR Quận 4', 'tranhoaid@example.com'),
('KH005', N'Vũ Anh E', '567890123456', N'202 Đường STU Quận 5', 'vuanhe@example.com');


INSERT INTO HH (MaHH, TenHH, Giatri, SoTienlan1, Sotiencaclantiep, MaKH)
VALUES 
('HH001', N'Điện thoại Samsung', 10000, 5000, 5000, 'KH001'),
('HH002', N'Tablet iPad', 15000, 7500, 7500, 'KH002'),
('HH003', N'Laptop Dell', 20000, 10000, 10000, 'KH003'),
('HH004', N'Máy tính xách tay HP', 18000, 9000, 9000, 'KH004'),
('HH005', N'TV Sony', 25000, 12500, 12500, 'KH005');

INSERT INTO PT (SoPT, MaKH, MaHH, Ngaythang, SoTientra, LoaiPT, GhiChu)
VALUES 
('PT001', 'KH001', 'HH001', '2024-12-01', 5000, N'0', N'Chuyển khoản'),
('PT002', 'KH002', 'HH002', '2024-12-02', 7500, N'1', N'Tiền mặt'),
('PT003', 'KH003', 'HH003', '2024-12-03', 10000, N'0', N'Chuyển khoản'),
('PT004', 'KH004', 'HH004', '2024-12-04', 9000, N'1', N'Tiền mặt'),
('PT005', 'KH005', 'HH005', '2024-12-05', 12500, N'0', N'Chuyển khoản');


SELECT * FROM KH;
SELECT * FROM HH;
SELECT * FROM PT;
select * from V_DuarasotientungKHphaitra
GO 

ALTER PROC SP_ThemPT (@SoPT VARCHAR(10), @MaKH VARCHAR(10), @MaHH varchar(10), @Ngaythang date , @SoTientra FLOAT, @LoaiPT VARCHAR(10), @GhiChu Ntext)
AS
BEGIN
    IF exists (select * from PT where SoPT = @SoPT) 
        PRINT N'Đã tồn tại mã phiếu thu trong hệ thống !!!'
    ELSE IF not exists (select * from PT where MaKH = @MaKH)
        PRINT N'Khong tồn tại MaKH trong hệ thống !!!'
    ELSE IF not exists (select * from PT where MaHH = @MaHH)
        PRINT N'Khong tồn tại MaHH trong hệ thống !!!'
    ELSE 
        BEGIN
        insert into PT(SoPT, MaKH, MaHH, Ngaythang, SoTientra, LoaiPT, GhiChu) values (@SoPT, @MaKH, @MaHH, @Ngaythang, @SoTientra, @LoaiPT, @GhiChu)
        END
END
GO

EXEC SP_ThemPT 'PT006','KH005','HH003','7-7-2023',125000,N'1',N'Giao ngoai gio hanh chinh'
go

CREATE VIEW V_DuarasotientungKHphaitra 
AS 
    SELECT KH.MAKH, KH.HoTenKH, KH.SoCCCD, KH.DC_LienHe, KH.Email, SUM(PT.SoTientra) AS tongtientra
    FROM KH
    JOIN PT ON KH.MAKH = PT.MaKH
    GROUP BY KH.MAKH, KH.HoTenKH, KH.SoCCCD, KH.DC_LienHe, KH.Email;
GO

SELECT * from V_DuarasotientungKHphaitra

--Thu tuc thong ke 
GO

ALTER PROC SP_THONGKE @option int , @thang INT
AS
BEGIN
    IF @option = 1 
    BEGIN
        SELECT count(*) FROM PT where MONTH(ngaythang) = @thang
    END
    ELSE if @option = 2
    BEGIN
        SELECT sum(SoTientra) 
        FROM PT WHERE LoaiPT = '1' and MONTH(ngaythang) = @thang
    END 
    ELSE PRINT N'Loi !!!'
END
GO

EXEC SP_THONGKE 1 , 7
EXEC SP_THONGKE 2, 12
go

SELECT * FROM KH;
SELECT * FROM HH;
SELECT * FROM PT;
CREATE trigger Tg_Capnhatsotientra 

ALTER TABLE HH ADD SoluongTK INT 
ALTER TABLE PT drop COLUMN LuongBan

update HH SET SoLuongTK = 100;
update HH SET Sotiencaclantiep = Sotiencaclantiep + 100;
GO

ALTER TRIGGER Trg_ThemSLmua on PT FOR INSERT
as 
BEGIN 
    UPDATE HH
    set SoluongTK = SoluongTK - (select SoLuongBan from inserted where inserted.MaHH = HH.MaHH) 
    FROM HH,inserted
    where HH.MaHH = inserted.MaHH 
END
GO

insert into PT(SoPT, MaKH, MaHH, Ngaythang, SoTientra, LoaiPT, GhiChu,SoluongBan) values ('PT007','KH004','HH001','7-7-2023',125000,N'1',N'Giao ngoai gio hanh chinh',30)

ALTER TRIGGER Trg_xoaSLMua ON PT FOR DELETE 
AS 
BEGIN 
    UPDATE HH 
    set SoluongTK = SoluongTK + SoluongBan
    FROM deleted , HH
    where deleted.MaHH = HH.MaHH
END
go

delete from PT where SoPT = 'PT007'
go

ALTER TRIGGER Trg_SuaSoluongmua on PT for UPDATE 
as 
BEGIN
    UPDATE HH
    set SoluongTK = SoluongTK 
    + (SELECT SoluongBan from deleted where deleted.MaHH = HH.MaHH) 
    - (SELECT SoluongBan from inserted where inserted.MaHH = HH.MaHH)
    from inserted,HH,PT
    where HH.MaHH = inserted.MaHH and PT.MaHH = HH.MaHH
END
GO

DISABLE Trigger Trg_SuaSoluongmua on PT
ENABLE Trigger Trg_SuaSoluongmua on PT

UPDATE PT SET SoLuongBan = 60 where MaHH = 'HH001'
UPDATE PT SET SoLuongBan = 20 where MaHH = 'HH002'
UPDATE PT SET SoLuongBan = 30 where MaHH = 'HH003'
UPDATE PT SET SoLuongBan = 40 where MaHH = 'HH004'
UPDATE PT SET SoLuongBan = 50 where MaHH = 'HH005'