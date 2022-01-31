INCLUDE 'EMU8086.INC'
.MODEL LARGE
.DATA 

  PLAYER_H DW 3d
  ENEMY_H DW 3d 
  PLAYER_P DW 2800d
  ENEMY_P DW 1710d
  ENEMY_MD DB 0d
   
  ENEMY_FIRE_S DB 0d
  ENEMY_BOOMP DW 10d 
  
  PLAYER_FIRE_S DB 0d
  PLAYER_MISILEP DW 20d  
  
  HEALTH_S DB 0d
  HEALTH_P DW 0d
  ENEMY_BOOM_MISS_COUNT DB 0d
  
  PLAYER_SCORE_ERASER DW 718d
  ENEMY_SCORE_ERASER DW 724d
    
  
  IN_GAME_SCREEN DW ' ' ,0Ah,0Dh
  DW '           USE LEFT AND RIGHT AROW KEY TO MOVE AND SPACEBAR TO FIRE  ', 0Ah,0Dh 
  DW '                   ----------------------------------------',0Ah,0Dh
  DW '                  |                                        |',0Ah,0Dh
  DW '                  | PLAYER HEALGHT +++    +++ ENEMY HEALTH |',0Ah,0Dh
  DW '                  |                                        |',0Ah,0Dh 
  DW '                   ----------------------------------------',0Ah,0Dh
  DW '                              SIMPLE SHOOTING GAME                ',0Ah,0Dh
  DW '                       _________________________________' ,0Ah,0Dh
  DW '                      |                                 |' ,0Ah,0Dh
  DW '                      |                                 |' ,0Ah,0Dh
  DW '                      |                                 |' ,0Ah,0Dh
  DW '                      |                                 |' ,0Ah,0Dh
  DW '                      |                                 |' ,0Ah,0Dh
  DW '                      |                                 |' ,0Ah,0Dh
  DW '                      |                                 |' ,0Ah,0Dh
  DW '                      |                                 |' ,0Ah,0Dh
  DW '                      |                                 |' ,0Ah,0Dh
  DW '                      |                                 |' ,0Ah,0Dh
  DW '                      |_________________________________|' ,0Ah,0Dh
  DW '                                    $' ,0Ah,0Dh
  

.CODE

MAIN PROC 
    MOV AX,@DATA
    MOV DS,AX 
    MOV AX,0B800h
    MOV ES,AX 
    
    MOV AH,9
    MOV DX, OFFSET IN_GAME_SCREEN
    INT 21H
            
     GAME_LOOP:
        MOV AH,1h
        INT 16h
        JNZ CLICKED
        JMP GAME
        GAME:
        CMP PLAYER_H,0
        JE GAME_OVER
        
        CMP ENEMY_H,0
        JE WIN
        
        DRAW_PLAYER:
            MOV BX,PLAYER_P
            MOV CL,246d
            MOV CH,1011b
            MOV ES:[BX],CX
            ADD BX,160d
            MOV CL,94d
            MOV CH,1011b
            MOV ES:[BX],CX 
            CMP PLAYER_FIRE_S,1d
         JE DRAW_PLAYERFIRE
         JNE DRAW_ENEMY:
         
         DRAW_PLAYERFIRE:
             MOV BX,PLAYER_MISILEP
             MOV CL,' '
             MOV CH,1111b
             MOV ES:[BX],CX
             
             SUB PLAYER_MISILEP,160
             MOV BX,PLAYER_MISILEP
             CMP BX,1440d
             JL  UPDATE_PLAYER_MISSILE_MISSED
             CMP BX,ENEMY_P
             JE  UPDATE_PLAYER_SCORE
             SUB BX,2d
             CMP BX,ENEMY_P
             JE  UPDATE_PLAYER_SCORE
             ADD BX,4d
             CMP BX,ENEMY_P
             JE  UPDATE_PLAYER_SCORE
             
             MOV BX,PLAYER_MISILEP        
             CMP BX,ENEMY_BOOMP
             JE  RESETBM_PLAYER
             MOV CL,12d 
             MOV CH,1011b
             MOV ES:[BX],CX
             JMP DRAW_ENEMY
             
        
        DRAW_ENEMY:
             CMP ENEMY_MD,0d
             JE DRAW_E_LEFT
             CMP ENEMY_MD,1d
             JE DRAW_E_RIGHT
        
        DRAW_E_LEFT:
            MOV ENEMY_MD,0d
            CMP ENEMY_P,1650d
            JE DRAW_E_RIGHT
            
            MOV BX,ENEMY_P
            ADD BX,2d
            MOV CL,' '
            MOV CH,1111b
            MOV ES:[BX],CX 
            SUB BX,2d
            MOV CL,62d
            MOV CH,1110b
            MOV ES:[BX],CX
            
            SUB ENEMY_P,2d
            MOV BX,ENEMY_P
            MOV CL,167d
            MOV CH,1110b
            MOV ES:[BX],CX
            SUB BX,2d
            MOV CL,60d
            MOV CH,1110b
            MOV ES:[BX],CX
            JMP ENEMYFIRE
        
        DRAW_E_RIGHT:
            MOV ENEMY_MD,1d
            CMP ENEMY_P,1710d
            JE DRAW_E_LEFT
            
            
            MOV BX,ENEMY_P
            SUB BX,2d
            MOV CL,' '
            MOV CH,1111b
            MOV ES:[BX],CX 
            ADD BX,2d
            MOV CL,60d
            MOV CH,1110b
            MOV ES:[BX],CX
            
            ADD ENEMY_P,2d
            MOV BX,ENEMY_P
            MOV CL,167d
            MOV CH,1110b
            MOV ES:[BX],CX
            
            ADD BX,2d
            MOV CL,62d
            MOV CH,1110b
            MOV ES:[BX],CX 
            
            JMP ENEMYFIRE
                    
            
        ENEMYFIRE:
            CMP ENEMY_FIRE_S,1d
            JE DRAW_EF
            JNE SET_ENEMY_FIRE
      
            SET_ENEMY_FIRE: 
                MOV BX,ENEMY_P
                ADD BX,1120 
                CMP BX,PLAYER_P
                JE START_FIRE
                JNE HEALTH
                
                START_FIRE:
                 
                MOV BX,ENEMY_P
                MOV BX,160 
                CMP BX,PLAYER_MISILEP
                JE  HEALTH
                MOV BX,ENEMY_P
                MOV ENEMY_BOOMP,BX
                MOV ENEMY_FIRE_S,1d
                JMP DRAW_EF       
        
        DRAW_EF:
  
            MOV BX,ENEMY_BOOMP
            MOV CL,' '
            MOV CH,1111b
            MOV ES:[BX],CX
 
            ADD ENEMY_BOOMP,160
            MOV BX,ENEMY_BOOMP
            CMP BX,PLAYER_P
            JE  UPDATE_ENEMY_SCORE
            CMP BX,2880d
            JG  UPDATE_ENEMY_BOOM_MISSED
            
            MOV CL,161
            MOV CH,1100b
            MOV ES:[BX],CX 
            MOV BX,PLAYER_MISILEP        
            CMP BX,ENEMY_BOOMP
            JE  RESETBM_ENEMY 
                  
         HEALTH:         
         CMP HEALTH_S,1d
         JNE CHECK_BOOM_MISSED
         JE DRAW_HEALTH
            CHECK_BOOM_MISSED: 
            CMP ENEMY_BOOM_MISS_COUNT ,2
            JE START_NEW_HEALTH
            JNE GAMELOOP_END
          
          
         START_NEW_HEALTH:
         MOV HEALTH_S,1d  
         MOV BX,PLAYER_P
         SUB BX,1120
         MOV HEALTH_P,BX
         JMP DRAW_HEALTH
         
        DRAW_HEALTH:
        MOV BX,HEALTH_P
        MOV CL,' ' 
        MOV CH, 1111b
        MOV ES:[BX],CX
        
        
        ADD HEALTH_P,160
        MOV BX,HEALTH_P
        MOV CL,246d 
        MOV CH, 0010b
        MOV ES:[BX],CX
        CMP PLAYER_P,BX
        JE INCREASE_HEALTH
        CMP BX,2880d
        JG HEALTH_MISSED
        
        
     GAMELOOP_END:
     JMP GAME_LOOP   
      
     CLICKED: 
     MOV AH,0
     INT 16H
     CMP AH,4Bh
     JE MOVELEFT
     
     CMP AH,4Dh
     JE MOVERIGHT
     
     CMP AH,39h 
     JE PLAYER_FIRE
     
     JMP GAME
     
     MOVELEFT:
            MOV BX,PLAYER_P
            MOV CL,' '
            MOV CH,1111b
            MOV ES:[BX],CX
            ADD BX,160d
            MOV CL,' '
            MOV CH,1111b
            MOV ES:[BX],CX
            SUB PLAYER_P,2d
            JMP GAME 
     
     
     MOVERIGHT:
            MOV BX,PLAYER_P
            MOV CL,' '
            MOV CH,1111b
            MOV ES:[BX],CX
            ADD BX,160d
            MOV CL,' '
            MOV CH,1111b
            MOV ES:[BX],CX           
            ADD PLAYER_P,2d
            JMP GAME
             
      PLAYER_FIRE:
            MOV BX,PLAYER_P 
            MOV PLAYER_MISILEP,BX
            MOV PLAYER_FIRE_S,1d
            JMP GAME
            
            
      UPDATE_ENEMY_SCORE:
            DEC PLAYER_H
            MOV ENEMY_FIRE_S,0d
            MOV ENEMY_BOOMP,10d
            
            SUB PLAYER_SCORE_ERASER,2d
            MOV BX,PLAYER_SCORE_ERASER
         
            MOV CL,' '
            MOV CH,1111b
            MOV ES:[BX],CX
            JMP HEALTH 
            
      UPDATE_ENEMY_BOOM_MISSED:
            MOV ENEMY_FIRE_S,0d
            MOV ENEMY_BOOMP,10d
            INC ENEMY_BOOM_MISS_COUNT
            JMP HEALTH 
            
              
      UPDATE_PLAYER_SCORE:
            DEC ENEMY_H 
            MOV PLAYER_FIRE_S,0d
            MOV PLAYER_MISILEp,20d  
            
            ADD ENEMY_SCORE_ERASER,2d 
            MOV BX,ENEMY_SCORE_ERASER
            MOV CL,' '
            MOV CH,1111b
            MOV ES:[BX],CX
            JMP DRAW_ENEMY
            
            
      UPDATE_PLAYER_MISSILE_MISSED:
            MOV PLAYER_FIRE_S,0d
            MOV PLAYER_MISILEp,20d
            JMP DRAW_ENEMY
            
      
      RESETBM_PLAYER: 
            MOV BX,ENEMY_BOOMP
            MOV CL,' '
            MOV CH,1111b
            MOV ES:[BX],CX
            MOV ENEMY_BOOMP,10d
            MOV PLAYER_MISILEP,20d
            MOV PLAYER_FIRE_S,0d
            MOV ENEMY_FIRE_S,0d
            JMP DRAW_ENEMY
      RESETBM_ENEMY: 
            MOV BX,ENEMY_BOOMP
            MOV CL,' '
            MOV CH,1111b
            MOV ES:[BX],CX
            MOV ENEMY_BOOMP,10d
            MOV PLAYER_MISILEP,20d
            MOV PLAYER_FIRE_S,0d
            MOV ENEMY_FIRE_S,0d
            JMP HEALTH
            
     INCREASE_HEALTH: 
           MOV HEALTH_S,0d
           MOV HEALTH_P,0d
           MOV ENEMY_BOOM_MISS_COUNT,0d
           CMP PLAYER_H,3d
           JE GAMELOOP_END
           INC PLAYER_H 
           MOV BX,PLAYER_SCORE_ERASER
           MOV CL,'+'
           MOV CH,1111b
           MOV ES:[BX],CX 
           ADD PLAYER_SCORE_ERASER,2d
           JMP GAMELOOP_END
     HEALTH_MISSED:
           MOV HEALTH_S,0d
           MOV ENEMY_BOOM_MISS_COUNT,0d
           MOV BX,HEALTH_P
           MOV CL,' '
           MOV CH,1111b
           MOV ES:[BX],CX 
           MOV HEALTH_P,0d
           JMP GAMELOOP_END 
                    
    GAME_OVER:
    PRINT 'YOU DIED'
    JMP CLOSE
    
    WIN:
    PRINT 'YOU WIN' 
    
    CLOSE:
    MOV AH,4CH
    INT 21H
    MAIN ENDP

END MAIN