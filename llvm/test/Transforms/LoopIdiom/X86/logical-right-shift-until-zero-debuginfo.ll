; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt -passes=debugify,loop-idiom -mtriple=x86_64 -mcpu=corei7 < %s -S | FileCheck %s --check-prefixes=NOLZCNT
; RUN: opt -passes=debugify,loop-idiom -mtriple=x86_64 -mcpu=core-avx2 < %s -S | FileCheck %s --check-prefixes=LZCNT

declare void @escape_inner(i8, i8, i8, i1, i8)
declare void @escape_outer(i8, i8, i8, i1, i8)

define i8 @p(i8 %val, i8 %start, i8 %extraoffset) {
; NOLZCNT-LABEL: @p(
; NOLZCNT-NEXT:  entry:
; NOLZCNT-NEXT:    br label [[LOOP:%.*]], !dbg [[DBG20:![0-9]+]]
; NOLZCNT:       loop:
; NOLZCNT-NEXT:    [[IV:%.*]] = phi i8 [ [[START:%.*]], [[ENTRY:%.*]] ], [ [[IV_NEXT:%.*]], [[LOOP]] ], !dbg [[DBG21:![0-9]+]]
; NOLZCNT-NEXT:      #dbg_value(i8 [[IV]], [[META9:![0-9]+]], !DIExpression(), [[DBG21]])
; NOLZCNT-NEXT:    [[NBITS:%.*]] = add nsw i8 [[IV]], [[EXTRAOFFSET:%.*]], !dbg [[DBG22:![0-9]+]]
; NOLZCNT-NEXT:      #dbg_value(i8 [[NBITS]], [[META11:![0-9]+]], !DIExpression(), [[DBG22]])
; NOLZCNT-NEXT:    [[VAL_SHIFTED:%.*]] = lshr i8 [[VAL:%.*]], [[NBITS]], !dbg [[DBG23:![0-9]+]]
; NOLZCNT-NEXT:      #dbg_value(i8 [[VAL_SHIFTED]], [[META12:![0-9]+]], !DIExpression(), [[DBG23]])
; NOLZCNT-NEXT:    [[VAL_SHIFTED_ISZERO:%.*]] = icmp eq i8 [[VAL_SHIFTED]], 0, !dbg [[DBG24:![0-9]+]]
; NOLZCNT-NEXT:      #dbg_value(i1 [[VAL_SHIFTED_ISZERO]], [[META13:![0-9]+]], !DIExpression(), [[DBG24]])
; NOLZCNT-NEXT:    [[IV_NEXT]] = add i8 [[IV]], 1, !dbg [[DBG25:![0-9]+]]
; NOLZCNT-NEXT:      #dbg_value(i8 [[IV_NEXT]], [[META14:![0-9]+]], !DIExpression(), [[DBG25]])
; NOLZCNT-NEXT:    call void @escape_inner(i8 [[IV]], i8 [[NBITS]], i8 [[VAL_SHIFTED]], i1 [[VAL_SHIFTED_ISZERO]], i8 [[IV_NEXT]]), !dbg [[DBG26:![0-9]+]]
; NOLZCNT-NEXT:    br i1 [[VAL_SHIFTED_ISZERO]], label [[END:%.*]], label [[LOOP]], !dbg [[DBG27:![0-9]+]]
; NOLZCNT:       end:
; NOLZCNT-NEXT:    [[IV_RES:%.*]] = phi i8 [ [[IV]], [[LOOP]] ], !dbg [[DBG28:![0-9]+]]
; NOLZCNT-NEXT:    [[NBITS_RES:%.*]] = phi i8 [ [[NBITS]], [[LOOP]] ], !dbg [[DBG29:![0-9]+]]
; NOLZCNT-NEXT:    [[VAL_SHIFTED_RES:%.*]] = phi i8 [ [[VAL_SHIFTED]], [[LOOP]] ], !dbg [[DBG30:![0-9]+]]
; NOLZCNT-NEXT:    [[VAL_SHIFTED_ISZERO_RES:%.*]] = phi i1 [ [[VAL_SHIFTED_ISZERO]], [[LOOP]] ], !dbg [[DBG31:![0-9]+]]
; NOLZCNT-NEXT:    [[IV_NEXT_RES:%.*]] = phi i8 [ [[IV_NEXT]], [[LOOP]] ], !dbg [[DBG32:![0-9]+]]
; NOLZCNT-NEXT:      #dbg_value(i8 [[IV_RES]], [[META15:![0-9]+]], !DIExpression(), [[DBG28]])
; NOLZCNT-NEXT:      #dbg_value(i8 [[NBITS_RES]], [[META16:![0-9]+]], !DIExpression(), [[DBG29]])
; NOLZCNT-NEXT:      #dbg_value(i8 [[VAL_SHIFTED_RES]], [[META17:![0-9]+]], !DIExpression(), [[DBG30]])
; NOLZCNT-NEXT:      #dbg_value(i1 [[VAL_SHIFTED_ISZERO_RES]], [[META18:![0-9]+]], !DIExpression(), [[DBG31]])
; NOLZCNT-NEXT:      #dbg_value(i8 [[IV_NEXT_RES]], [[META19:![0-9]+]], !DIExpression(), [[DBG32]])
; NOLZCNT-NEXT:    call void @escape_outer(i8 [[IV_RES]], i8 [[NBITS_RES]], i8 [[VAL_SHIFTED_RES]], i1 [[VAL_SHIFTED_ISZERO_RES]], i8 [[IV_NEXT_RES]]), !dbg [[DBG33:![0-9]+]]
; NOLZCNT-NEXT:    ret i8 [[IV_RES]], !dbg [[DBG34:![0-9]+]]
;
; LZCNT-LABEL: @p(
; LZCNT-NEXT:  entry:
; LZCNT-NEXT:    [[VAL_NUMLEADINGZEROS:%.*]] = call i8 @llvm.ctlz.i8(i8 [[VAL:%.*]], i1 false), !dbg [[DBG20:![0-9]+]]
; LZCNT-NEXT:    [[VAL_NUMACTIVEBITS:%.*]] = sub nuw nsw i8 8, [[VAL_NUMLEADINGZEROS]], !dbg [[DBG20]]
; LZCNT-NEXT:    [[TMP0:%.*]] = sub i8 0, [[EXTRAOFFSET:%.*]], !dbg [[DBG21:![0-9]+]]
; LZCNT-NEXT:    [[VAL_NUMACTIVEBITS_OFFSET:%.*]] = add nsw i8 [[VAL_NUMACTIVEBITS]], [[TMP0]], !dbg [[DBG20]]
; LZCNT-NEXT:    [[IV_FINAL:%.*]] = call i8 @llvm.smax.i8(i8 [[VAL_NUMACTIVEBITS_OFFSET]], i8 [[START:%.*]]), !dbg [[DBG20]]
; LZCNT-NEXT:    [[LOOP_BACKEDGETAKENCOUNT:%.*]] = sub nsw i8 [[IV_FINAL]], [[START]], !dbg [[DBG20]]
; LZCNT-NEXT:    [[LOOP_TRIPCOUNT:%.*]] = add nuw nsw i8 [[LOOP_BACKEDGETAKENCOUNT]], 1, !dbg [[DBG20]]
; LZCNT-NEXT:    br label [[LOOP:%.*]], !dbg [[DBG21]]
; LZCNT:       loop:
; LZCNT-NEXT:    [[LOOP_IV:%.*]] = phi i8 [ 0, [[ENTRY:%.*]] ], [ [[LOOP_IV_NEXT:%.*]], [[LOOP]] ], !dbg [[DBG20]]
; LZCNT-NEXT:    [[LOOP_IV_NEXT]] = add nuw nsw i8 [[LOOP_IV]], 1, !dbg [[DBG22:![0-9]+]]
; LZCNT-NEXT:    [[LOOP_IVCHECK:%.*]] = icmp eq i8 [[LOOP_IV_NEXT]], [[LOOP_TRIPCOUNT]], !dbg [[DBG22]]
; LZCNT-NEXT:    [[IV:%.*]] = add nsw i8 [[LOOP_IV]], [[START]], !dbg [[DBG22]]
; LZCNT-NEXT:      #dbg_value(i8 [[IV]], [[META9:![0-9]+]], !DIExpression(), [[DBG20]])
; LZCNT-NEXT:    [[NBITS:%.*]] = add nsw i8 [[IV]], [[EXTRAOFFSET]], !dbg [[DBG22]]
; LZCNT-NEXT:      #dbg_value(i8 [[NBITS]], [[META11:![0-9]+]], !DIExpression(), [[DBG22]])
; LZCNT-NEXT:    [[VAL_SHIFTED:%.*]] = lshr i8 [[VAL]], [[NBITS]], !dbg [[DBG23:![0-9]+]]
; LZCNT-NEXT:      #dbg_value(i8 [[VAL_SHIFTED]], [[META12:![0-9]+]], !DIExpression(), [[DBG23]])
; LZCNT-NEXT:      #dbg_value(i1 [[LOOP_IVCHECK]], [[META13:![0-9]+]], !DIExpression(), [[META24:![0-9]+]])
; LZCNT-NEXT:    [[IV_NEXT:%.*]] = add i8 [[IV]], 1, !dbg [[DBG25:![0-9]+]]
; LZCNT-NEXT:      #dbg_value(i8 [[IV_NEXT]], [[META14:![0-9]+]], !DIExpression(), [[DBG25]])
; LZCNT-NEXT:    call void @escape_inner(i8 [[IV]], i8 [[NBITS]], i8 [[VAL_SHIFTED]], i1 [[LOOP_IVCHECK]], i8 [[IV_NEXT]]), !dbg [[DBG26:![0-9]+]]
; LZCNT-NEXT:    br i1 [[LOOP_IVCHECK]], label [[END:%.*]], label [[LOOP]], !dbg [[DBG27:![0-9]+]]
; LZCNT:       end:
; LZCNT-NEXT:    [[IV_RES:%.*]] = phi i8 [ [[IV_FINAL]], [[LOOP]] ], !dbg [[DBG28:![0-9]+]]
; LZCNT-NEXT:    [[NBITS_RES:%.*]] = phi i8 [ [[NBITS]], [[LOOP]] ], !dbg [[DBG29:![0-9]+]]
; LZCNT-NEXT:    [[VAL_SHIFTED_RES:%.*]] = phi i8 [ [[VAL_SHIFTED]], [[LOOP]] ], !dbg [[DBG30:![0-9]+]]
; LZCNT-NEXT:    [[VAL_SHIFTED_ISZERO_RES:%.*]] = phi i1 [ [[LOOP_IVCHECK]], [[LOOP]] ], !dbg [[DBG31:![0-9]+]]
; LZCNT-NEXT:    [[IV_NEXT_RES:%.*]] = phi i8 [ [[IV_NEXT]], [[LOOP]] ], !dbg [[DBG32:![0-9]+]]
; LZCNT-NEXT:      #dbg_value(i8 [[IV_RES]], [[META15:![0-9]+]], !DIExpression(), [[DBG28]])
; LZCNT-NEXT:      #dbg_value(i8 [[NBITS_RES]], [[META16:![0-9]+]], !DIExpression(), [[DBG29]])
; LZCNT-NEXT:      #dbg_value(i8 [[VAL_SHIFTED_RES]], [[META17:![0-9]+]], !DIExpression(), [[DBG30]])
; LZCNT-NEXT:      #dbg_value(i1 [[VAL_SHIFTED_ISZERO_RES]], [[META18:![0-9]+]], !DIExpression(), [[DBG31]])
; LZCNT-NEXT:      #dbg_value(i8 [[IV_NEXT_RES]], [[META19:![0-9]+]], !DIExpression(), [[DBG32]])
; LZCNT-NEXT:    call void @escape_outer(i8 [[IV_RES]], i8 [[NBITS_RES]], i8 [[VAL_SHIFTED_RES]], i1 [[VAL_SHIFTED_ISZERO_RES]], i8 [[IV_NEXT_RES]]), !dbg [[DBG33:![0-9]+]]
; LZCNT-NEXT:    ret i8 [[IV_RES]], !dbg [[DBG34:![0-9]+]]
;
entry:
  br label %loop

loop:
  %iv = phi i8 [ %start, %entry ], [ %iv.next, %loop ]
  %nbits = add nsw i8 %iv, %extraoffset
  %val.shifted = lshr i8 %val, %nbits
  %val.shifted.iszero = icmp eq i8 %val.shifted, 0
  %iv.next = add i8 %iv, 1

  call void @escape_inner(i8 %iv, i8 %nbits, i8 %val.shifted, i1 %val.shifted.iszero, i8 %iv.next)

  br i1 %val.shifted.iszero, label %end, label %loop

end:
  %iv.res = phi i8 [ %iv, %loop ]
  %nbits.res = phi i8 [ %nbits, %loop ]
  %val.shifted.res = phi i8 [ %val.shifted, %loop ]
  %val.shifted.iszero.res = phi i1 [ %val.shifted.iszero, %loop ]
  %iv.next.res = phi i8 [ %iv.next, %loop ]

  call void @escape_outer(i8 %iv.res, i8 %nbits.res, i8 %val.shifted.res, i1 %val.shifted.iszero.res, i8 %iv.next.res)

  ret i8 %iv.res
}
