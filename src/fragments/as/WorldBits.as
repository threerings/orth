// Code fragments involving MemberService
// ======================================


// from WorldController
// ====================


    /**
     * Handles the GO_MEMBER_HOME command.
     */
    public function handleGoMemberHome (memberId :int) :void
    {
        _wctx.getWorldDirector().goToMemberHome(memberId);
    }

