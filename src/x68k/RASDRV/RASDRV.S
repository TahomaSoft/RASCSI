*---------------------------------------------------------------------------
*
*  SCSI Target Emulator RaSCSI (*^..^*)
*  for Raspberry Pi
*
*  Powered by XM6 TypeG Technorogy.
*  Copyright (C) 2016-2017 GIMONS
*	[ �z�X�g�t�@�C���V�X�e�� �u���b�W�h���C�o ]
*
* Based on
*	X68k Emulator Host Filesystem Driver version 0.27
*	Programmed By co
*
*---------------------------------------------------------------------------

	CPU	68010

	INCLUDE	DOSCALL.MAC
	INCLUDE IOCSCALL.MAC

.XREF	_Init, _Process		;bridge.c  

COMMAND	EQU	2	�R�}���h�ԍ�
ERRLOW	EQU	3	�G���[�R�[�h����8�r�b�g
ERRHIGH	EQU	4	�G���[�R�[�h���8�r�b�g
MXUNIT	EQU	13	���j�b�g��
DEVEND	EQU	14	�h���C�o�I���A�h���X
BDEVNO	EQU	22	�x�[�X�h���C�u�ԍ�

DDHEADER:
	DC.L	-1		+$00	�����N�|�C���^
	DC.W	$2040		+$04	�f�o�C�X����
	DC.L	DDSTRATEGY	+$06
	DC.L	DDENTRY_FIRST	+$0A
	DC.B	'*EMUHOST'	+$0E	�f�o�C�X��

DDREQUEST:
	DC.L	0

DDSTRATEGY:
	MOVE.L	A5,DDREQUEST
	RTS

*�f�o�C�X�h���C�o�G���g��
DDENTRY:
	MOVE.L	SP,(STACK_BUFF)
	LEA	(DEF_STACK),SP
	MOVEM.L	D1-D3/A0-A2,-(SP)
	MOVEM.L	DDREQUEST(PC),D0	D0.L: ���N�G�X�g�w�b�_�A�h���X
	MOVE.L	D0,-(SP)
	BSR		_Process
	ADDQ.L	#4,SP
	MOVEM.L	(SP)+,D1-D3/A0-A2
	MOVEA.L	(STACK_BUFF),SP
	RTS

KEEP_HERE:

*����݂̂̃f�o�C�X�h���C�o�G���g��
DDENTRY_FIRST:
	MOVEM.L	D1-D3/A0-A2/A5,-(SP)
	MOVEA.L	DDREQUEST(PC),A5	A5.L: ���N�G�X�g�w�b�_�A�h���X
*	CMPI.B	#$40,COMMAND(A5)	���s��Human68k�ł̓`�F�b�N�s�v
*	BNE	UNSUPPORTED		�G���[:	���Ή�

*�^�C�g���\��
	PEA	MESSAGE_TITLE(PC)
	DOS	_PRINT
	ADDQ.L	#4,SP

*�f�o�C�X�`�F�b�N
DEVICE_CHECK:
	BSR _Init

	TST.L	D0
	BEQ	NOTFOUND		�G���[: �f�o�C�X�����݂��܂���

*�풓�J�n
	LEA	DDENTRY(PC),A1

	LEA	DDHEADER+$0A(PC),A0
	MOVE.L	A1,(A0)			�h���C�o�G���g����ݒ�
	MOVE.L	#PROG_END,DEVEND(A5)		�풓�I���A�h���X��ݒ�

	ST.B	MXUNIT(A5)		�|�[�g�������̔���̂��ߕ��̒l��ݒ肵�Ă���
	JSR	(A1)			�h���C�o�G���g�������s

	TST.B	MXUNIT(A5)		���j�b�g���m�F
	BLE	NODRIVE			�G���[: �h���C�u������܂���

	MOVE.B	BDEVNO(A5),D0
	MOVE.B	MXUNIT(A5),D1
	LEA	FIRSTDRIVE(PC),A0
	ADD.B	D0,(A0)			�J�n�h���C�u����������
	ADD.B	D1,D0			�I���h���C�u����������
	ADD.B	D0,LASTDRIVE-FIRSTDRIVE(A0)

	PEA	MESSAGE_DRIVENAME(PC)	����: �h���C�uA:
	DOS	_PRINT

	PEA	MESSAGE_DRIVENAME2(PC)	����: ����Z:
	SUBQ.B	#2,D1
	BCS	@F
	DOS	_PRINT
@@	ADDQ.L	#8,SP

	PEA	MESSAGE_DRIVENAME3(PC)	����: ��o�^���܂���
	BRA	QUIT

NOTFOUND:
	PEA	MESSAGE_NOTFOUND(PC)	�G���[: �f�o�C�X�����݂��܂���
	BRA	ABORT

UNSUPPORTED:
	PEA	MESSAGE_UNSUPPORTED(PC)	�G���[: ���Ή�
	BRA	ABORT

NODRIVE:
	PEA	MESSAGE_NODRIVE(PC)	�G���[: �h���C�u������܂���

ABORT:
	MOVE.B	#$0D,ERRLOW(A5)
	MOVE.B	#$70,ERRHIGH(A5)

QUIT:
	DOS	_PRINT
	ADDQ.L	#4,SP

	MOVEM.L	(SP)+,D1-D3/A0-A2/A5
	RTS

SECRET:
	PEA	MESSAGE_TITLE2(PC)
	DOS	_PRINT
	PEA	CREDIT(PC)
	DOS	_PRINT
	ADDQ.L	#8,SP
	DOS	_EXIT

	DATA

*�G���[���b�Z�[�W
MESSAGE_NOTFOUND:
	DC.B	'�f�o�C�X�����݂��܂���',$0D,$0A,0

MESSAGE_UNSUPPORTED:
	DC.B	'���Ή�',$0D,$0A,0

MESSAGE_NODRIVE:
	DC.B	'�h���C�u������܂���',$0D,$0A,0

*�o�^���b�Z�[�W
MESSAGE_DRIVENAME:
	DC.B	'�h���C�u'
FIRSTDRIVE:
	DC.B	'A:',0
MESSAGE_DRIVENAME2:
	DC.B	'����'
LASTDRIVE:
	DC.B	'@:',0
MESSAGE_DRIVENAME3:
	DC.B	'��o�^���܂���',$0D,$0A,0

*�^�C�g��
MESSAGE_TITLE:
	DC.B	$0D,$0A
MESSAGE_TITLE2:
	DC.B	'RaSCSI FileSystem Driver version 1.21',$0D,$0A,0

*���肪�Ƃ��I
CREDIT:
	DC.B	'Coded by GIMONS',$0D,$0A
	DC.B	'Special thanks to',$0D,$0A
	DC.B	9,'co',$0D,$0A
	DC.B	9,'�o�h�D',$0D,$0A
	DC.B	9,'���ԁ��K���Z��',$0D,$0A
	DC.B	0

	BSS
	QUAD

STACK_BUFF:
	.DS.L	1

	STACK
	QUAD

	.DS.B	1024*2
DEF_STACK:


PROG_END:
	END	SECRET