-- 알림함 비우기 — 알림을 지울 수 있게 한다 (2026-11-18)
--
-- 왜: 알림함(public.notification_log)은 '읽음'만 표시할 수 있어서, 한 번 쌓인 알림이 목록에 계속 남았다.
--     그래서 종·탭 제목·홈 화면 배지의 안 읽은 숫자를 지울 방법이 없었다. 이제 사람이 자기 알림을
--     한 줄씩 또는 전부 지울 수 있다. (지운 줄은 되돌릴 수 없다)
--
-- 누가: 로그인한 사람이 자기 줄만 (user_id = auth.uid()). 남의 알림은 보이지도, 지워지지도 않는다.
-- 무엇을 바꾸나
--   · authenticated 에 delete 권한 (전에는 select, update(read_at) 만 있었다)
--   · notify_log_delete 정책 — 지우기는 내 줄만

grant delete on public.notification_log to authenticated;

drop policy if exists notify_log_delete on public.notification_log;
create policy notify_log_delete on public.notification_log for delete to authenticated
  using (user_id = (select auth.uid()));

comment on table public.notification_log is '알림함. 넣는 것은 트리거(신청 승인·반려, 역할 변경)와 함수만 — 브라우저는 자기 것만 읽고, 읽음 표시하고, 지운다. 본문에 개인정보를 넣지 않는다(앱 이름·결정만).';

-- 새 권한을 PostgREST 가 바로 알아보게 한다
notify pgrst, 'reload schema';
