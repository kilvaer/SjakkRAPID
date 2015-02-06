MODULE ChessTest
    VAR bool capturePiece;
    VAR bool checkMate;
    VAR bool gripperOpenPos;
    VAR bool waitForTurn;
    
    CONST num boardHeight:=12;  !chess board z-height over table
    CONST num fieldSize:=50;    !5cm tiles
    
    PERS tooldata tCalibrate:=[TRUE,[[0,0,258.5],[1,0,0,0]],[5,[85,0,85],[1,0,0,0],0.012,0.012,0.012]];
    PERS tooldata tGripper:=[TRUE,[[0,0,165],[1,0,0,0]],[5,[85,0,85],[1,0,0,0],0.012,0.012,0.012]];

    CONST robtarget pInitPos:=[[100,200,300],[1,0,0,0],[0,0,0,0],[9E9,9E9,9E9,9E9,9E9,9E9]]; !FYLL INN RETTE VERDIER
    CONST robtarget pClock:=[[100,200,300],[1,0,0,0],[0,0,0,0],[9E9,9E9,9E9,9E9,9E9,9E9]]; !FYLL INN RETTE VERDIER
    CONST robtarget pPieceLocation:=[[100,200,300],[1,0,0,0],[0,0,0,0],[9E9,9E9,9E9,9E9,9E9,9E9]]; !FYLL INN RETTE VERDIER
    
    TASK PERS wobjdata obEnvironment:=[FALSE,TRUE,"",[[0,0,0],[1,0,0,0]],[[0,0,0],[1,0,0,0]]]; !Må kalibreres
    TASK PERS wobjdata obChessBoard:=[FALSE,TRUE,"",[[0,0,0],[1,0,0,0]],[[0,0,0],[1,0,0,0]]]; !Fyll inn rett info ift obChessBoard
    !finn ut hva TASK betyr.
    
    
    
    
    PROC Init()
        capturePiece:=FALSE;
        checkMate:=TRUE;
        waitForTurn:=TRUE;
        OpenGripper;
    ENDPROC
    
    
    PROC CloseGripper()
        !insert code for closing gripper
        !Wait for signal: "gripperOpenPos=false"        
    ENDPROC
    
    PROC OpenGripper()
        !insert code for opening the gripper
        !waiting for signal: "gripperOpenPos=true"
    ENDPROC
    
    
    PROC MoveInitPos()
        !Finn beste "venteposisjon" for roboten        
        MoveJ pInitPos,v1000,z10,tGripper\WObj:=obChessBoard;
    ENDPROC
    
    
    
    PROC MovePiece()
        
    ENDPROC
    
    
    PROC PressClock()
        MoveJ Offs(pClock, 0, 0, 50),v7000,z50,tGripper\WObj:=obEnvironment; !5cm above clock
        MoveJ pClock,v1000,fine,tGripper\WObj:=obEnvironment;
        MoveJ Offs(pClock, 0, 0, 50),v7000,z50,tGripper\WObj:=obEnvironment; !5cm above clock
    ENDPROC
    
    
    PROC Main()
        Init;
        WHILE checkMate=FALSE DO
            !waiting for signal "waitForTurn=false"
            
            WHILE waitForTurn=FALSE DO
                
                IF (capturePiece=TRUE) THEN
                    MovePiece; !move open gripper to captured piece
                    CloseGripper;
                    MovePiece; !move captured piece off to designated area
                    OpenGripper;
                    MoveInitPos;
                
                    capturePiece:=FALSE;
                ENDIF
            
                IF (capturePiece=FALSE) THEN
                    MovePiece;
                    CloseGripper;
                    MovePiece; !move captured piece off to designated area
                    OpenGripper;
                    PressClock;
                    MoveInitPos;
                
                ENDIF
                waitForTurn:=TRUE;
                
            ENDWHILE !waitForTurn
                       
        ENDWHILE !CheckMate
    ENDPROC!Main
    
ENDMODULE