// Code fragments involving ItemService
// ====================================


// from WorldController
// ====================

    /** Command to view an item, arg is an ItemIdent. */
    public static const VIEW_ITEM :String = "ViewItem";

    /** Command to flag an item, arg is an ItemIdent. */
    public static const FLAG_ITEM :String = "FlagItem";

    /** Command to indicate an audio item was clicked, arg is [ mediaDesc ] */
    public static const AUDIO_CLICKED :String = "AudioClicked";

    /**
     * Handles the VIEW_ITEM command.
     */
    public function handleViewItem (ident :EntityIdent) :void
    {
        var resultHandler :Function = function (result :Object) :void {
            if (result == null) {
                // it's an object we own, or it's not listed but we are support+
                displayPage("stuff", "d_" + ident.type + "_" + ident.itemId);

            } else if (result == 0) {
                _wctx.displayFeedback(OrthCodes.ITEM_MSGS,
                    MessageBundle.compose("m.not_listed", Item.getTypeKey(ident.type)));

            } else {
                displayPage("shop", "l_" + ident.type + "_" + result);
            }
        };
        var isvc :ItemService = _wctx.getClient().requireService(ItemService) as ItemService;
        isvc.getCatalogId(ident, _wctx.resultListener(resultHandler));
    }

    /**
     * Handles the FLAG_ITEM command.
     */
    public function handleFlagItem (ident :EntityIdent) :void
    {
        new FlagItemDialog(_wctx, ident);
    }

    public function handleAudioClicked (desc :MediaDesc, ident :EntityIdent) :void
    {
        if (desc == null) {
            return;
        }

        var mediaId :String = desc.getMediaId();
        var kind :String = Msgs.GENERAL.get(Item.getTypeKey(Item.AUDIO));
        var menuItems :Array = [];
        menuItems.push({ label: Msgs.GENERAL.get("b.view_item", kind),
            command: WorldController.VIEW_ITEM, arg: ident });
        if (_wctx.isRegistered()) {
            menuItems.push({ label: Msgs.GENERAL.get("b.flag_item", kind),
                command: WorldController.FLAG_ITEM, arg: ident });
        }

        CommandMenu.createMenu(menuItems, _topPanel).popUpAtMouse();
    }



// from RoomObjectController
// =========================

        } else { // shown when clicking on someone else
            if (avatar == null) {
                return;
            }
            var kind :String = Msgs.GENERAL.get(avatar.getDesc());
            var flagItems :Array = [];

            var ident :EntityIdent = avatar.getEntityIdent();
            if (ident != null && ident.getType() >= 0) { // -1 is the default avatar, etc
                flagItems.push({ label: Msgs.GENERAL.get("b.view_item", kind),
                    command: WorldController.VIEW_ITEM, arg: ident });
                if (!us.isPermaguest()) {
                    flagItems.push({ label: Msgs.GENERAL.get("b.flag_item", kind),
                        command: WorldController.FLAG_ITEM, arg: ident });
                }
            }

            // finally, add whatever makes sense
            if (flagItems.length != 0) {
                CommandMenu.addSeparator(menuItems);
            }
            if (flagItems.length > 0) {
                menuItems.push({ label: Msgs.GENERAL.get("l.item_menu", kind), icon: Resources.AVATAR_ICON,
                    children: flagItems });
            }
