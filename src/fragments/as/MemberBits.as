// Code fragments involving MemberService
// ======================================


// from WorldController
// ====================

    /**
     * Handles the COMPLAIN_MEMBER command.
     */
    public function handleComplainMember (memberId :int, username :String) :void
    {
        var service :Function = function (complaint :String) :void {
            msvc().complainMember(memberId, complaint);
        };

        _topPanel.callLater(function () :void { new ComplainDialog(_wctx, username, service); });
    }

    /**
     * Handles INVITE_FRIEND.
     */
    public function handleInviteFriend (memberId :int) :void
    {
        _wctx.getMemberDirector().inviteToBeFriend(memberId);
    }

    /**
     * Handles booting a user.
     */
    public function handleBootFromPlace (memberId :int) :void
    {
        var svc :MemberService = _wctx.getClient().requireService(MemberService) as MemberService;
        svc.bootFromPlace(memberId, _wctx.confirmListener());
    }



    /**
     * Convenience.
     */
    protected function msvc () :MemberService
    {
        return MemberService(_wctx.getClient().requireService(MemberService));
    }


