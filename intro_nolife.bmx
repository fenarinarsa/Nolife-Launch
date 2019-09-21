Strict
'version 1.2 uniquement
'SetGraphicsDriver GLMax2DDriver()

Incbin "\basic\nolife_test3.tga"
Incbin "\basic\fontjap2.tga"
Incbin "\basic\intro.wav"

Const ScnWidth=768
Const ScnHeight=576
Const ScnW=ScnWidth/2
Const ScnH=ScnHeight/2
Const Record=0
Const Music=1

Graphics ScnWidth,ScnHeight,0

'--------------------------
' STARFIELD
'--------------------------

Type star
	Field x:Double, y:Double, z:Double, angl:Double, anglv:Double, zv:Double, bo:Int

	Function createStar:star()
		Local myStar:star = New star
		myStar.x = Rnd(-ScnW,ScnW)
		myStar.y = Rnd(-ScnH,ScnH)
		myStar.z = 100
'		myStar.angl = Rnd(0,360)
'		myStar.anglv = Rnd(-5,5)
		myStar.zv = Rnd(0.5,2)
		myStar.bo = 0
		Return myStar
	End Function

	Function createStarBo:star(newX:Double,newY:Double)
		Local myStar:star = New star
		myStar.x = newX
		myStar.y = newY
		myStar.z = 400
'		myStar.angl = Rnd(0,360)
'		myStar.anglv = Rnd(-5,5)
		myStar.zv = 3
		myStar.bo = 1
		Return myStar
	End Function

	Method moveStar()
		z :- zv
		Local myx = x / z *100
		Local myy = y / z *100

		If myx < -ScnW Or myx >= ScnWidth Or myy < -ScnH Or myx >= ScnHeight Or z < 1
			If bo=0
				x = Rnd(-ScnW,ScnW)
				y = Rnd(-ScnH,ScnH)
				z = 100
'			angl = Rnd(0,360)
'			anglv = Rnd(-5,5)
				zv = Rnd(0.5,3)
			Else
				bo=2
			EndIf
		End If

'		angl = angl + anglv
		Return bo
	End Method

	Method drawStar()
		If bo<2
			Local myx = x / z *100
			Local myy = y / z *100

			
			Local cols
			If bo=0
				cols = 255*(100-z)/100
			Else
				cols = 255*(400-z)/400
			EndIf

			SetColor(cols,cols,cols)
			'Plot myx+ScnWidth/2 , myy+ScnHeight/2
			DrawRect myx+ScnWidth/2 , myy+ScnHeight/2,3,3
		EndIf
		
	End Method

End Type

Type starField Extends TList

	Method doStarField()

		Local cStar:star
		Local bi:Int
		For cStar = EachIn Self

			bi=cStar.moveStar()
			If bi<2
				cStar.drawStar
			Else
				remove(cStar)
			EndIf
		Next
	 	SetColor 255,255,255

	End Method

End Type

'--------------------------
' Courbes
'--------------------------

Function deformY(effet:Int,theTimer:Double,x:Int)

	Select effet
	Case 1
		'D?formation ample et lente
		Return 20*Sin(theTimer/30)*Sin(theTimer/5+(2*x))
	Case 2
		'D?formation r?duite et rapide
		Return 5*Sin(theTimer/3+x*5)
	Default
		Return 0
	End Select
	
End Function

Function deformX(effet:Int,theTimer:Double,y:Int)

	Select effet
	Case 1
		'D?formation ample et lente
		Return 50*Sin(theTimer/20+y)
	Case 2
		'D?formation r?duite et rapide
		Return 10*Sin(theTimer/3+y*5)
	Case 3
		'D?formation double et ample
		Return 100*Sin(myTimer/10+y+(180*(y Mod 2)))
	Default
		Return 0
	End Select
	
End Function

' -------------------------------

Function between:Double(x:Double,bottom:Double,top:Double)
	If x < bottom
		Return bottom
	Else If x > top
		Return top
	Else Return x
	EndIf
End Function

Function between_bin:Double(x:Double,bottom:Double,top:Double)
	Local ret:Double
	If x < bottom
		ret=0
	Else If x > top
		ret=1
	Else
		ret=(x-bottom)/(top-bottom)
	EndIf
	Return ret
End Function

'--------------------------
' Main
'--------------------------


Global muzak:TSound = LoadSound( "incbin::\basic\intro.wav")
Global i,j,k:Int=0
Global grologo_pic:TPixmap=LoadPixmap("incbin::\basic\nolife_test3.tga")
Global x,y:Int=0
Global color:Long=0
'Global grologo_picx=PixmapWidth(grologo_pic)
'Global grologo_picy=PixmapHeight(grologo_pic)
Global grologo_largeur=PixmapWidth(grologo_pic)
Global grologo_hauteur=PixmapHeight(grologo_pic)
'Global nolife_logo:logo = logo.create(grologo_picx,grologo_picy)
Global RecordTGA:TPixmap
Global numTGA:Int=0

'Global logo_deformx:Int[ScnHeight]
'Global logo_deformy:Int[ScnWidth]

' Choppe le logo ligne par ligne
Cls


SetBlend(ALPHABLEND)
DrawPixmap(grologo_pic,0,0)
'Global logo_ligne:TPixmap[grologo_hauteur]
Global logo_ligne:TImage[grologo_hauteur]

'' BORDEL Pour rendre transparent chaque tranche du logo
'' (bug MaskPixmap ne marche pas)

SetMaskColor(255, 0, 0)
Local mypixmap:TPixmap
'Local myimage:TImage=CreateImage(grologo_largeur,1,DYNAMICIMAGE|MASKEDIMAGE)
For i=0 To grologo_hauteur-1
'	logo_ligne[i]=MaskPixmap(GrabPixmap(0,i,grologo_largeur,1),$ff,0,0)
'	logo_ligne[i]=GrabPixmap(0,i,grologo_largeur,1)
	logo_ligne[i]=CreateImage(grologo_largeur,1,DYNAMICIMAGE|MASKEDIMAGE)
	GrabImage logo_ligne[i],0,i
	mypixmap=LockImage(logo_ligne[i])
'	mypixmap=MaskPixmap(mypixmap,255,0,0)
	UnlockImage(logo_ligne[i])
	logo_ligne[i]=LoadImage(mypixmap,MASKEDIMAGE)	
Next 
Cls

'===================================
' PREPARATION POLICE + SCROLLTEXT
'===================================

' NEWFONT
'Global fontorder:String="ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890.:!?-(),' "
' FONTJAP2
Global fontorder:String="ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789.:'"+Chr$($22)+"?!_- abcdefghijklmnopqrstuvwxyz"
Const caraclarg=16
Const carachaut=13
Global font_pic:TPixmap=LoadPixmap("incbin::\basic\fontjap2.tga")
Global font_largeur:Int=PixmapWidth(font_pic)
Global font_hauteur:Int=PixmapHeight(font_pic)
Global font:TImage[256]
Global alpha:Double=0

' POLICE TEMPORAIRE
'Const ScaleText=5
'SetColor(0,0,255)
'SetScale(ScaleText,ScaleText)
'SetMaskColor(0, 0, 0)
'For i=32 To 127
'	Cls
'	DrawText(Chr(i),0,0)
'	font[i]=CreateImage(8*ScaleText,10*ScaleText,DYNAMICIMAGE|MASKEDIMAGE)
'	GrabImage font[i],0,ScaleText
'Next
'Cls
'SetScale(1,1)

' POLICE DEFINITIVE
Cls
For i=0 To 255
	font[k]=CreateImage(caraclarg,carachaut,DYNAMICIMAGE|MASKEDIMAGE)
	GrabImage font[k],0,0
Next
SetBlend(ALPHABLEND)
DrawPixmap(font_pic,0,0)
SetMaskColor(255, 0, 255)
'Local mypixmap:TPixmap
'Local myimage:TImage=CreateImage(caraclarg,carachaut,DYNAMICIMAGE|MASKEDIMAGE)
For i=0 To (Len fontorder)-1
	k=Asc(Mid$(fontorder,i+1,1))
	font[k]=CreateImage(caraclarg,carachaut,DYNAMICIMAGE|MASKEDIMAGE)
	GrabImage font[k],((i*caraclarg) Mod font_largeur),((i*caraclarg) / font_largeur)*carachaut
	mypixmap=LockImage(font[k])
	UnlockImage(font[k])
	font[k]=LoadImage(mypixmap,MASKEDIMAGE)
	MidHandleImage(font[k])
'	Flip
'	WaitKey
Next 
Cls

Global scrolltext:String="                    "
scrolltext:+"                    "
scrolltext:+"                    "
scrolltext:+"                    "
scrolltext:+"                    "
scrolltext:+"                    "
scrolltext:+"                    "
scrolltext:+"                    "
scrolltext:+" aON N'Y CROYAIT PLUS ET POURTANT VOICI NOLIFE QUI DEVRAIT COMMENCER "
scrolltext:+"D'ICI DEUX MINUTES. ENFIN... NORMALEMENT... "
scrolltext:+"                              d"
scrolltext:+"LES CREDITS POUR CETTE PETITE INTRO "
scrolltext:+"SPECIALE...   CODE: RICK ST    GFX: PHAN-NGC ET DAVY-UCEM "
scrolltext:+"   ZIK: SHIMOMURA YOKO z"
scrolltext:+"                      f"
scrolltext:+"GREETINGS TO JUST ET SEBFAZ AINSI QUE TOUS LES GENS QUI ONT CRU "
scrolltext:+"AU PROJET ET A TOUTE L'EQUIPE... AND TO YOU!         "
scrolltext:+"                    ye"
scrolltext:+"PLUS QUE QUELQUES SECONDES AVANT QUE LES PROGRAMMES NE COMMENCENT... "
scrolltext:+"AU FAIT... ETES-VOUS CAPABLE DE TROUVER LE HIDDEN SCREEN ?     LET'S WRAAAAAAAAAAAAAAAAAAAAAAAAAAAP... "
scrolltext:+"                    "
Global text_len=Len scrolltext
Global textpointer:Int=0
Const textwindow=20
Global charx,chary,scrolleffect,activatestars:Int
Global letterspace,oldtimer,oldtmpTimer:Double
scrolleffect=0
activatestars=0


Global timer,myTimer:Long,tmpTimer,scrollTimer,oldscrollTimer:Double
'Const decompte:Long=3*60*1000  '2*3600*1000
Const decompte:Long=(2.2)*60*1000  '2*3600*1000
'Const decompte:Long=$00100000  '2*3600*1000
Global logox, logoy:Int
Global ampdef,petitesin,grossesin:Double
Global movelogo:Double
'Global toto:Int

Local test1,test2,test3,test4:Long
Local def1,def2:Long,effet1x,effet2x,effet1y,effet2y:Int,transition:Float
Local mySF:starField = New starField
Local nbcls:Long=0

'For y=0 To grologo_picy-1
'	For x=0 To grologo_picx-1
'		color=ReadPixel(grologo_pic,x,y)	
'		If (color & $FFFFFF)<>$0
'			nolife_logo.addLast pixel_logo.create(x,y,color)
'		EndIf
'	Next
'Next

If music<>0
	PlaySound (muzak)
EndIf
timer=MilliSecs()
myTimer=0
ScrollTimer=0
While Not KeyHit(KEY_ESCAPE)
	Cls
'	DrawPixmap(grologo_pic,0,0)
	oldtimer=myTimer
	If Record=0
		myTimer=(MilliSecs()-timer)
	Else
		' 20ms (50fps)
		myTimer:+20
	EndIf
	tmpTimer=myTimer / 10
	oldtmpTimer=oldtimer / 10
	mySF.doStarField
	If activatestars>0
		If nbcls < 800
			' Add 400 stars
			mySF.addLast star.createStar()
		End If
		nbcls:+1
	EndIf
	If activatestars>1
		For i=0 To 4
		mySF.addLast star.createStarBo((ScnW)*Cos(tmpTimer/.9+i*72),(ScnW)*-Sin(tmpTimer/.9+i*72))
'		mySF.addLast star.createStarBo((ScnW)*Cos(tmpTimer/.9+i*36),(ScnW)*-Sin(tmpTimer/.9+i*36))
'		mySF.addLast star.createStarBo((ScnW)*Cos(tmpTimer/.9+i*36),(ScnW)*Sin(tmpTimer/.9+i*36))
		Next
	EndIf
'	(((tmpTimer+i)-360)/3.6)*Sin((tmptimer+i)/10.0)+Sin((tmptimer+i)/3.0)
'	If myTimer<5000
'		effet1y=0
'		effet2y=0
'		transition=0
'	ElseIf myTimer<7000
'		tmpTimer:-5000
'		effet1y=0
'		effet2y=1
'		transition=tmpTimer/2000
'	ElseIf myTimer<10000
'		tmpTimer:-7000
'		effet1y=1
'		effet2y=0
'		transition=0
'	ElseIf myTimer<12000
'		tmpTimer:-10000
'		effet1y=1
'		effet2y=2
'		transition=tmpTimer/2000
'	Else
'		tmpTimer:-12000
'		effet1y=2
'		effet2y=2
'		transition=0
'	EndIf


	' Affichage compteur
	SetColor(255,255,255)
	SetScale(5,5)
	DrawText(Hex(decompte-myTimer),(ScnWidth-8*5*8)/2,350)
	SetScale(1,1)

'=====================
' SCROLLTEXT
'=====================

	' EFFETS : (scrolleffect)
	' 00 = normal normal
	' 01 = normal balancier 
	' 10 = sin
	' 11 = sin balancier
	' 20 = roto
	' 21 = roto balancier

'	SetHandle(caraclarg/2,caraclarg/2)
	SetBlend(alphablend)
	SetScale(3,3)
	
	oldScrollTimer=scrollTimer
	If scrolleffect<20
		' Scrolltext normal
		Letterspace=caraclarg*3
		scrollTimer=tmpTimer*3 Mod LetterSpace
	Else 
		' Rotoscroll
		Letterspace=360/textwindow
		scrollTimer=tmpTimer Mod LetterSpace
	EndIf
	
	If scrollTimer<(LetterSpace/2) And oldscrollTimer>(LetterSpace/2)
		textpointer:+1
		If textpointer>=text_len-textwindow
			textpointer=0
		EndIf

		' Declenchement des effets
		Select Mid$(scrolltext,textpointer+textwindow,1)
		Case "a"
			scrolleffect=0
		Case "b"
			scrolleffect=1
		Case "c"
			scrolleffect=10
		Case "d"
			scrolleffect=11
		Case "e"
			scrolleffect=20
		Case "f"
			scrolleffect=21
		Case "z"
			activatestars=1
		Case "y"
			activatestars=2
		End Select
		
	EndIf

'	DrawText(Mid$(scrolltext,1+textpointer,1),0,20)
	
	For i=0 To textwindow-1

		Select scrolleffect
		Case 0,10
			' Normal ou sin
			SetRotation(0)
		Case 1,11,21
			' Ca balance !
			SetRotation(70*Sin(tmpTimer*2))
		Case 20
			' ROTO : Ca tourne dans le bon sens	
			SetRotation(90-(scrollTimer+(textwindow-i-1)*LetterSpace))
		End Select						

	    ' ROTO : Ca retourne de temps en temps
'		SetRotation(180*between_bin(Cos(tmpTimer/3),0.45,0.55)+90-(scrollTimer+(textwindow-i-1)*LetterSpace))
		' Idem scrolltext normal
'		SetRotation(180*between_bin(Cos(tmpTimer/3),0.45,0.55))

		If scrolleffect<10
			' Scrolltext normal
			charx=i*Letterspace+Letterspace-ScrollTimer-(LetterSpace*textwindow)/2+ScnW
			chary=490
		Else If scrolleffect<20
			' sin
			charx=i*Letterspace+Letterspace-ScrollTimer-(LetterSpace*textwindow)/2+ScnW
			chary=430-50*Sin(35+(scrollTimer+(textwindow-i-1)*LetterSpace)/2)
		Else
			' Rotoscroll
			charx=ScnW+210*Cos((scrollTimer+(textwindow-i-1)*LetterSpace))
			chary=ScnH-210*Sin((scrollTimer+(textwindow-i-1)*LetterSpace))
		EndIf
		
		' Transparence progressive debut/fin scrolltext
		If i=0
			alpha=1-scrolltimer/(letterspace*1.0)
		Else If i=textwindow-1
			alpha=scrolltimer/(letterspace*1.0)
		Else
			alpha=1
		EndIf
		SetAlpha(alpha)
		
		DrawImage(font[Asc(Mid$(scrolltext,1+textpointer+i,1))],charx,chary)
	Next

'=====================
' LOGO
'=====================
'	SetHandle(0,0)
	SetScale(1,1)
	SetAlpha(1)
	SetRotation(0)
	
'	DrawText("tmptimer="+tmptimer,200,350)
	If tmpTimer<(360*5)
		movelogo=0
'	DrawText("1",200,370)
	Else If tmpTimer<(360*10)
		movelogo=(tmpTimer-(360*5))/(360*5)
'	DrawText("2",200,370)
	Else
		movelogo=Sin(tmptimer/10)	
'	DrawText("3",200,380)
	EndIf
	movelogo=0
'	DrawText("movelogo="+movelogo,200,360)
	
	logox=(ScnW-grologo_largeur/2)+(ScnW*0.2)*Sin(myTimer/10)*movelogo
	logoy=(ScnH-grologo_hauteur/2)-10+(ScnH*0.7)*Cos(mytimer/15)*movelogo
	For i=0 To grologo_hauteur-1
		If tmpTimer+i<360
			ampdef=0	
		Else If tmpTimer+i<(360*2)
			ampdef=((tmpTimer+i)-360)/3.6
		Else
			ampdef=100
		EndIf
		
'		If tmptimer+i>=(360*2)
'			If ((tmpTimer+i) Mod 180) < 36
'				petitesin=10*Sin(((tmptimer+i) Mod 180)*10)*Sin((tmptimer+i)/10.0)
'			Else
'				petitesin=0
'			EndIf
'		EndIf

		grossesin = Sin((tmptimer+i)/10.0)+Sin((tmptimer+i)/3.0)
			

		DrawImage logo_ligne[i],logox+grossesin*ampdef*Sin(tmptimer+i)+petitesin,logoy+i
	Next


'	DrawText(grossesin,200,400)
	
	If Record<>0
		RecordTGA=GrabPixmap(0,0,ScnWidth,ScnHeight)
		SavePixmapPNG(recordTGA,"record\image"+Replace$(RSet$(numTGA,5)," ","0")+".png",0)
		numTGA:+1
	EndIf
	Flip

Wend
'RecordTGA=GrabPixmap(0,0,ScnWidth,ScnHeight)
'SavePixmapPNG(recordTGA,"screenshot.png",0)
