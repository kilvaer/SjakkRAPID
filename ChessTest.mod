MODULE SjakkTest
   
    CONST num boardHeight:=12;  !chess board z-height over table
    CONST num fieldSize:=50;    !5cm tiles
    
    VAR num beatenPieceCounter;     !Counts the beaten pieces
    VAR num beatenOffsetCounter;    !adjusts where beaten pieces are put off-board
    
    VAR bool capturePiece;
    VAR bool checkMate;
    PERS bool waitForTurn;
    VAR string CastlingState;
    
    VAR num xMaster;    !Coordinate used for Robot
    VAR num yMaster;
    VAR num xCoord1;    !Value range: 0-7
    VAR num yCoord1;    !Value range: 0-7
    VAR num xCoord2;
    VAR num yCoord2;
    
    VAR bool EnPassantActive;
    VAR num xEnPassant;
    VAR num yEnPassant;
    
    PERS tooldata tCalibrate:=[TRUE,[[0,0,258.5],[1,0,0,0]],[5,[85,0,85],[1,0,0,0],0.012,0.012,0.012]];
    !PERS tooldata tGripper:=[TRUE,[[0,0,165],[1,0,0,0]],[5,[85,0,85],[1,0,0,0],0.012,0.012,0.012]];
    
    PERS robtarget pPieceLocationZero:=[[0,0,0],[0,0,1,0],[0,0,0,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
    PERS robtarget pClock:=[[610,250,40],[0,0,1,0],[0,0,-1,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
    PERS robtarget pInitPos:=[[-100,500,250],[0,0,1,0],[0,0,-1,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
    PERS robtarget pPieceOffBoardLocationZero:=[[0,0,0],[0,0,1,0],[0,0,0,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
    
    TASK PERS wobjdata obChessBoard:=[FALSE,TRUE,"",[[700,-200,12],[0.707106781,0,0,0.707106781]],[[0,0,0],[1,0,0,0]]];
    TASK PERS wobjdata obTable:=[FALSE,TRUE,"",[[750,-350,0],[0.707106781,0,0,0.707106781]],[[0,0,0],[1,0,0,0]]];
    
    
    
    PROC Init()        
        xCoord1:=1;
        yCoord1:=1;
        xCoord2:=1;
        yCoord2:=1;
        
        capturePiece:=FALSE;
        checkMate:=FALSE;
        waitForTurn:=TRUE; !SKAL VÆRE TRUE
        
        beatenPieceCounter:=0;
        beatenOffsetCounter:=1;
        
        EnPassantActive:=FALSE;
        xEnPassant:=1;
        yEnPassant:=1;
        
        CastlingState:="";
        
        CloseGripper;        
    ENDPROC
    
    PROC OpenGripper()
        !insert code for opening the gripper
        !waiting for signal: "gripperOpenPos=true"
    ENDPROC
    
    PROC CloseGripper()
        !insert code for closing gripper
        !Wait for signal: "gripperOpenPos=false"
    ENDPROC
    
    PROC MovePiecePick()
        MoveJ Offs(pPieceLocationZero, xMaster*fieldSize - .5*fieldSize, yMaster*fieldSize - .5*fieldSize, 110),v7000,z50,tCalibrate\WObj:=obChessBoard; !11 cm above board
        OpenGripper;
        MoveL Offs(pPieceLocationZero, xMaster*fieldSize - .5*fieldSize, yMaster*fieldSize - .5*fieldSize, 3),v7000,fine,tCalibrate\WObj:=obChessBoard; !At piece position, 3mm above board
        CloseGripper;
        MoveJ Offs(pPieceLocationZero, xMaster*fieldSize - .5*fieldSize, yMaster*fieldSize - .5*fieldSize, 110),v7000,z50,tCalibrate\WObj:=obChessBoard; !11 cm above board
    ENDPROC
    
    PROC MovePieceDeliver()
        MoveJ Offs(pPieceLocationZero, xMaster*fieldSize - .5*fieldSize, yMaster*fieldSize - .5*fieldSize, 110),v7000,z50,tCalibrate\WObj:=obChessBoard; !11 cm above board
        MoveL Offs(pPieceLocationZero, xMaster*fieldSize - .5*fieldSize, yMaster*fieldSize - .5*fieldSize, 3),v7000,fine,tCalibrate\WObj:=obChessBoard; !At piece position, 3mm above board
        OpenGripper;
        MoveJ Offs(pPieceLocationZero, xMaster*fieldSize - .5*fieldSize, yMaster*fieldSize - .5*fieldSize, 110),v7000,z50,tCalibrate\WObj:=obChessBoard; !11 cm above board
        CloseGripper;
    ENDPROC
    
    PROC PieceOffBoard()
        MoveL Offs(pPieceLocationZero, xMaster*fieldSize - .5*fieldSize, yMaster*fieldSize - .5*fieldSize, 110),v7000,z50,tCalibrate\WObj:=obChessBoard; !11 cm above board
        
        
        IF (beatenPieceCounter=6) THEN
            beatenPieceCounter:=1;
            beatenOffsetCounter:=beatenOffsetCounter+1;
        ENDIF
        
        MoveL Offs(pPieceLocationZero, -.8*fieldSize*beatenOffsetCounter ,400 - .80*fieldSize*beatenPieceCounter, -boardHeight+110),v7000,z50,tCalibrate\WObj:=obChessBoard; !11 cm above board
        
        MoveL Offs(pPieceLocationZero, -.8*fieldSize*beatenOffsetCounter ,400 - .80*fieldSize*beatenPieceCounter,-boardHeight),v7000,z50,tCalibrate\WObj:=obChessBoard;
        OpenGripper;
        MoveL Offs(pPieceLocationZero, -.8*fieldSize*beatenOffsetCounter ,400 - .80*fieldSize*beatenPieceCounter,-boardHeight+110),v7000,z50,tCalibrate\WObj:=obChessBoard; !11 cm above board
    
        CloseGripper;
        beatenPieceCounter:=beatenPieceCounter+1;
    ENDPROC
    
    PROC Castling()
        IF (CastlingState="WShort") THEN
            xMaster:=5;
            yMaster:=1;
            MovePiecePick;
            xMaster:=7;
            MovePieceDeliver;
            xMaster:=8;
            MovePiecePick;
            xMaster:=6;
            MovePieceDeliver;           
        ENDIF
        
        IF (CastlingState="WLong") THEN
            xMaster:=5;
            yMaster:=1;
            MovePiecePick;
            xMaster:=3;
            MovePieceDeliver;
            xMaster:=1;
            MovePiecePick;
            xMaster:=4;
            MovePieceDeliver;           
        ENDIF
        
        IF (CastlingState="BShort") THEN
            xMaster:=5;
            yMaster:=8;
            MovePiecePick;
            xMaster:=7;
            MovePieceDeliver;
            xMaster:=8;
            MovePiecePick;
            xMaster:=6;
            MovePieceDeliver;           
        ENDIF
        
        IF (CastlingState="BLong") THEN
            xMaster:=5;
            yMaster:=8;
            MovePiecePick;
            xMaster:=3;
            MovePieceDeliver;
            xMaster:=1;
            MovePiecePick;
            xMaster:=4;
            MovePieceDeliver;           
        ENDIF
        
        CastlingState:="";
    ENDPROC
    
    PROC EnPassant()
        xMaster:=xEnPassant;
        yMaster:=yEnPassant;
        
        MovePiecePick;
        PieceOffBoard;
        
        EnPassantActive:=FALSE;
        xEnPassant:=1;
        yEnPassant:=1;
    ENDPROC
    
    PROC PressClock()
        MoveJ Offs(pClock, 0, 0, 50),v7000,z50,tCalibrate\WObj:=obTable; !5cm above clock
        MoveL pClock,v1000,fine,tCalibrate\WObj:=obTable;
        MoveL Offs(pClock, 0, 0, 50),v7000,z50,tCalibrate\WObj:=obTable; !5cm above clock
    ENDPROC
    
    PROC MoveInitPos()
        MoveJ pInitPos,v7000,z50,tCalibrate\WObj:=obTable;
        WaitTime 0.5;
    ENDPROC
    
    PROC PickCoord()
        xMaster:=xCoord1+1;
        yMaster:=yCoord1+1;
    ENDPROC
    
    PROC DeliverCoord()
        xMaster:=xCoord2+1;
        yMaster:=yCoord2+1;
    ENDPROC
    
    
    PROC Main()
        Init;
        WHILE checkMate=FALSE DO
            !waiting for signal "waitForTurn=false"
            WHILE waitForTurn=FALSE DO
                
                IF (capturePiece=TRUE) THEN
                    DeliverCoord;
                    MovePiecePick; !move open gripper to captured piece
                    PieceOffBoard;               
                    capturePiece:=FALSE;
                ENDIF
                
                !vanlig trekk:
                IF (CastlingState="") THEN
                    PickCoord;
                    MovePiecePick;
                    DeliverCoord;
                    MovePieceDeliver; !move captured piece off to designated area
                ENDIF
                
                IF (EnPassantActive=TRUE) THEN
                    EnPassant;
                ENDIF

                Castling;
                
                !Utføres hver gang:
                PressClock;
                MoveInitPos;               
                waitForTurn:=TRUE;
                
            ENDWHILE !waitForTurn
                       
        ENDWHILE !CheckMate
    ENDPROC!Main
    
ENDMODULE