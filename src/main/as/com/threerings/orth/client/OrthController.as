//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.

package com.threerings.orth.client {
import flash.display.DisplayObject;
import flash.display.Stage;
import flash.events.ContextMenuEvent;
import flash.events.IEventDispatcher;
import flash.events.TextEvent;
import flash.geom.Point;
import flash.ui.ContextMenu;
import flash.utils.Dictionary;

import flashx.funk.ioc.inject;

import com.threerings.util.CommandEvent;
import com.threerings.util.Controller;
import com.threerings.util.DelayUtil;
import com.threerings.util.Log;
import com.threerings.util.MessageBundle;
import com.threerings.util.NetUtil;
import com.threerings.util.StringUtil;

import com.threerings.orth.aether.client.AetherClient;
import com.threerings.orth.aether.client.AetherDirector;
import com.threerings.orth.aether.client.FriendDirector;
import com.threerings.orth.aether.data.AetherCredentials;
import com.threerings.orth.aether.data.PlayerName;
import com.threerings.orth.data.OrthCodes;
import com.threerings.orth.guild.client.GuildDirector;
import com.threerings.orth.guild.data.GuildRank;
import com.threerings.orth.locus.client.LocusDirector;
import com.threerings.orth.locus.data.Locus;
import com.threerings.orth.party.client.PartyDirector;

public class OrthController extends Controller
{
    /** Command to log us on. */
    public static const LOGON :String = "Logon";

    /** Command to log us off. */
    public static const LOGOFF :String = "Logoff";

    /** Command to move to a certain locus. */
    public static const GO_LOCUS :String = "GoLocus";

    /** Command to show an (external) URL. */
    public static const VIEW_URL :String = "ViewUrl";

    /** Command to invite someone to be a friend. */
    public static const INVITE_FRIEND :String = "InviteFriend";

    /** Command to accept a previously sent friend invitation. */
    public static const ACCEPT_FRIEND_INVITATION :String = "AcceptFriendInvitation";

    /** Command to invite someone to join a guild. */
    public static const INVITE_TO_GUILD :String = "InviteToGuild";

    /** Command to accept a previously sent guild invitation. */
    public static const ACCEPT_GUILD_INVITATION :String = "AcceptGuildInvitation";

    /** Command to leave the current guild. */
    public static const LEAVE_GUILD :String = "LeaveGuild";

    /** Command to leave and delete the current guild. */
    public static const DISBAND_GUILD :String = "DisbandGuild";

    /** Command to remove another player from the current guild. */
    public static const REMOVE_FROM_GUILD :String = "RemoveFromGuild";

    /** Command to set the rank of another player in the current guild. */
    public static const SET_GUILD_MEMBER_RANK :String = "SetGuildMemberRank";

    /** Command to create a party. */
    public static const CREATE_PARTY :String = "CreateParty";

    /** Command to join a party. */
    public static const JOIN_PARTY :String = "JoinParty";

    /** Command to invite a member to the current party. */
    public static const INVITE_TO_PARTY :String = "InviteToParty";

    /** Command to request detailed info on a party. */
    public static const GET_PARTY_DETAIL :String = "GetPartyDetail";

    /** Command to create a new guild. */
    public static const CREATE_GUILD :String = "CreateGuild";

    public function OrthController ()
    {
        setControlledPanel(_topPanel);

        var menu :ContextMenu = new ContextMenu();
        menu.hideBuiltInItems();
        menu.addEventListener(ContextMenuEvent.MENU_SELECT, contextMenuWillPopUp);
        _topPanel.contextMenu = menu;
    }

    /**
     * Handles the LOGON command.
     */
    public function handleLogon (creds :AetherCredentials) :void
    {
        // give the client a chance to log off, then log back on
        DelayUtil.delayFrame(function () :void {
            log.info("Logging on", "creds", creds, "version", _depCon.version);
            _client.logonWithCredentials(creds);
        });
    }

    /**
     * Handles the LOGOFF command.
     */
    public function handleLogoff () :void
    {
        DelayUtil.delayFrame(function () :void {
            _client.logoff(true);
        });
    }

    /**
     * Handles the GO_LOCUS command.
     */
    public function handleGoLocus (locus :Locus) :void
    {
        _locusDir.moveTo(locus);
    }

    /**
     * Convenience method for opening an external window and showing the specified url. This is
     * done when we want to show the user something without unloading the client.
     *
     * Also, handles VIEW_URL.
     *
     * @param url The url to show
     * @param windowOrTab the identifier of the tab to use, like _top or _blank, or null to
     * use the default, which is the same as _blank, I think. :)
     *
     * @return true on success
     */
    public function handleViewUrl (url :String, windowOrTab :String = null) :Boolean
    {
        // if our page refers to a Whirled page...
        if (NetUtil.navigateToURL(url, windowOrTab)) {
            return true;
        }

        _octx.displayFeedback(OrthCodes.GENERAL_MSGS, MessageBundle.tcompose("e.no_navigate", url));

        return false;
    }

    /**
     * Handles INVITE_FRIEND.
     */
    public function handleInviteFriend (invitee :PlayerName) :void
    {
        _friendDir.inviteFriend(invitee);
    }

    /**
     * Handles ACCEPT_FRIEND_INVITATION.
     */
    public function handleAcceptFriendInvitation (playerId :int) :void
    {
        _friendDir.acceptFriendInvite(playerId);
    }

    /**
     * Handles INVITE_TO_GUILD.
     */
    public function handleInviteToGuild (playerId :int) :void
    {
        _guildDir.invite(playerId);
    }

    /**
     * Handles ACCEPT_GUILD_INVITATION.
     */
    public function handleAcceptGuildInvitation (playerId :int, guildId :int) :void
    {
        _aetherDir.acceptGuildInvite(playerId, guildId);
    }

    /**
     * Handles LEAVE_GUILD.
     */
    public function handleLeaveGuild () :void
    {
        _guildDir.leave();
    }

    /**
     * Handles DISBAND_GUILD.
     */
    public function handleDisbandGuild () :void
    {
        _guildDir.disband();
    }

    /**
     * Handles REMOVE_FROM_GUILD.
     */
    public function handleRemoveFromGuild (playerId :int) :void
    {
        _guildDir.remove(playerId);
    }

    /**
     * Handles SET_GUILD_MEMBER_RANK.
     */
    public function handleSetGuildMemberRank (playerId :int, rank :GuildRank) :void
    {
        _guildDir.setRank(playerId, rank);
    }

    /**
     * Handles CREATE_GUILD.
     */
    public function handleCreateGuild (name :String) :void
    {
        _aetherDir.createGuild(name);
    }

    /**
     * Handles INVITE_TO_PARTY.
     */
    public function handleInviteToParty (playerId :int) :void
    {
        _partyDir.invitePlayer(playerId);
    }

    /**
     * Handles the CREATE_PARTY command.
     */
    public function handleCreateParty (name :String, inviteAllFriends :Boolean) :void
    {
        _partyDir.createParty(name, inviteAllFriends);
    }

    /**
     * Handles the JOIN_PARTY command.
     */
    public function handleJoinParty (partyId :int) :void
    {
        _partyDir.joinParty(partyId);
    }

    /**
     * Handles the GET_PARTY_DETAIL command.
     */
    public function handleGetPartyDetail (partyId :int) :void
    {
        // ORTH TODO
        //         _partyDir.getPartyDetail(partyId);
    }

    override protected function setControlledPanel (panel :IEventDispatcher) :void
    {
        // in addition to listening for command events, let's listen
        // for LINK events and handle them all here.
        if (_controlledPanel != null) {
            _controlledPanel.removeEventListener(TextEvent.LINK, handleLink);
        }
        super.setControlledPanel(panel);
        if (_controlledPanel != null) {
            _controlledPanel.addEventListener(TextEvent.LINK, handleLink);
        }
    }

    /**
     * Handles a TextEvent.LINK event.
     */
    protected function handleLink (evt :TextEvent) :void
    {
        var url :String = evt.text;
        if (StringUtil.startsWith(url, COMMAND_URL)) {
            var cmd :String = url.substring(COMMAND_URL.length);
            var sep :String = "/";
            // Sometimes we need to parse cmd args that have "/" in them, but we like using "/"
            // as our normal separator. So if the first character of the command is \uFFFC, then
            // chop that out and use \uFFFC as our separator.
            if (cmd.charAt(0) == "\uFFFC") {
                sep = "\uFFFC";
                cmd = cmd.substr(1);
            }
            var argStr :String = null;
            var slash :int = cmd.indexOf(sep);
            if (slash != -1) {
                argStr = cmd.substring(slash + 1);
                cmd = cmd.substring(0, slash);
            }
            var arg :Object = (argStr == null || argStr.indexOf(sep) == -1)
                ? argStr : argStr.split(sep);
            CommandEvent.dispatch(evt.target as IEventDispatcher, cmd, arg);

        } else {
            // A regular URL
            handleViewUrl(url);
        }
    }

    /**
     * Called to process ContextMenuEvent.MENU_SELECT.
     */
    protected function contextMenuWillPopUp (event :ContextMenuEvent) :void
    {
        var menu :ContextMenu = (event.target as ContextMenu);
        var custom :Array = menu.customItems;
        custom.length = 0;

        populateContextMenu(custom);

        // then, the menu will pop up
    }

    protected function populateContextMenu (custom :Array) :void
    {
        try {
            var allObjs :Array =
                _stage.getObjectsUnderPoint(new Point(_stage.mouseX, _stage.mouseY));
            var seen :Dictionary = new Dictionary();
            for each (var disp :DisplayObject in allObjs) {
                try {
                    while (disp != null && !(disp in seen)) {
                        seen[disp] = true;
                        if (disp is ContextMenuProvider) {
                            (disp as ContextMenuProvider).populateContextMenu(custom);
                        }
                        disp = disp.parent;
                    }
                } catch (serr :SecurityError) {
                    // that's ok, let's move on
                }
            }
        } catch (e :Error) {
            log.warning("Error populating context menu", e);
        }
    }

    protected const _octx :OrthContext = inject(OrthContext);
    protected const _stage :Stage = inject(Stage);
    protected const _topPanel :TopPanel = inject(TopPanel);
    protected const _client :AetherClient = inject(AetherClient);
    protected const _depCon :OrthDeploymentConfig = inject(OrthDeploymentConfig);

    protected const _partyDir :PartyDirector = inject(PartyDirector);
    protected const _locusDir :LocusDirector = inject(LocusDirector);
    protected const _aetherDir :AetherDirector = inject(AetherDirector);
    protected const _friendDir :FriendDirector = inject(FriendDirector);
    protected const _guildDir :GuildDirector = inject(GuildDirector);

    /** The URL prefix for 'command' URLs, that post CommendEvents. */
    protected static const COMMAND_URL :String = "command://";

    protected static var log :Log = Log.getLog(OrthController);
}
}
