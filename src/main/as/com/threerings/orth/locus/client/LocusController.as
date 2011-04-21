//
// $Id: LocusController.as 19431 2010-10-22 22:08:36Z zell $

package com.threerings.orth.locus.client {
import flash.display.DisplayObject;
import flash.display.Stage;
import flash.events.Event;
import flash.events.IEventDispatcher;
import flash.events.KeyboardEvent;
import flash.events.TimerEvent;
import flash.geom.Point;
import flash.text.TextField;
import flash.utils.Timer;
import flash.utils.getTimer;

import flashx.funk.ioc.inject;

import com.threerings.crowd.chat.client.ChatCantStealFocus;
import com.threerings.crowd.chat.data.ChatCodes;
import com.threerings.crowd.data.CrowdCodes;
import com.threerings.flex.ChatControl;

import com.threerings.util.Controller;
import com.threerings.util.Log;

import com.threerings.presents.client.ClientEvent;

import com.threerings.orth.client.TopPanel;

/**
 * A persistent controller for the top UI element; this is not torn down and reconstructed
 * as we move about the locus. It is a companion to OrthController that handles the directly
 * locus-related activities.
 */
public class LocusController extends Controller
{
    public function LocusController ()
    {
        _client.addServiceGroup(CrowdCodes.CROWD_GROUP);
        _client.addEventListener(ClientEvent.CLIENT_FAILED_TO_LOGON,
            function (event :ClientEvent) :void {
                // ORTH TODO: how do we let implementors do something nice here?
                //        _topPanel.setMainView(new DisconnectedPanel(
                //                _client, event.getCause().message, reconnectClient));
            });
        _client.addEventListener(ClientEvent.CLIENT_CONNECTION_FAILED, function (..._) :void {
            _logoffMessage = "m.lost_connection";
            });
        _client.addEventListener(ClientEvent.CLIENT_DID_LOGOFF, clientDidLogoff);

        // create a timer to poll mouse position and track timing
        _idleTimer = new Timer(1000);
        _idleTimer.addEventListener(TimerEvent.TIMER, handlePollIdleMouse);

        setControlledPanel(_topPanel.root);
        _stage.addEventListener(KeyboardEvent.KEY_DOWN, handleKeyDown, false, int.MAX_VALUE);
    }

    /**
     * Are we currently idle, i.e. no input for a period of time? This precludes away-ness.
     */
    public function isIdle () :Boolean
    {
        return _idle;
    }

    public function clientDidLogoff (event :ClientEvent) :void
    {
        log.info("clientDidLogoff()", "event", event, "client", _client);
        if (_logoffMessage != null) {
            // ORTH TODO: how do we let implementors do something nice here?
            _logoffMessage = null;
        } else {
            _topPanel.clearMainView();
        }
    }

    /**
     * Can be called with nearly any event (or none) to reset the idle tracking.
     * This function is public because it may be registered as an event listener for
     * components that have access to events in a different security boundary.
     */
    public function resetIdleTracking (event :Event = null) :void
    {
        _idleStamp = getTimer();
        setIdle(false);
    }

    override protected function setControlledPanel (panel :IEventDispatcher) :void
    {
        _idleTimer.reset();
        super.setControlledPanel(panel);
        if (_controlledPanel != null) {
            _idleTimer.start();
            resetIdleTracking();
        }
    }

    /**
     * Handles global key events.
     */
    protected function handleKeyDown (event :KeyboardEvent) :void
    {
        resetIdleTracking(event);

        // We check every keyboard event, see if it's a "word" character,
        // and then if it's not going somewhere reasonable, route it to chat.
        var c :int = event.charCode;
        if (c != 0 && !event.ctrlKey && !event.altKey &&
                // these are the ascii values for '/', a -> z,  A -> Z
                (c == 47 || (c >= 97 && c <= 122) || (c >= 65 && c <= 90))) {
            checkChatFocus();
        }
    }

    protected function handlePollIdleMouse (event :TimerEvent) :void
    {
        var panel :DisplayObject = DisplayObject(_controlledPanel);
        var mousePoint :Point = new Point(panel.mouseX, panel.mouseY);
        if (_idleMousePoint == null || !_idleMousePoint.equals(mousePoint)) {
            // we are not idle: either we just started, or a key event was detected,
            // or the mouse moved.
            _idleMousePoint = mousePoint;
            resetIdleTracking();

        } else if (!isNaN(_idleStamp) && (getTimer() - _idleStamp >= ChatCodes.DEFAULT_IDLE_TIME)) {
            _idleStamp = NaN;
            setIdle(true);
        }
    }

    /**
     * Update our idle status.
     */
    protected function setIdle (nowIdle :Boolean) :void
    {
        if (nowIdle != _idle) {
            _idle = nowIdle;
// ORTH TODO: this call will need to go over the aether client, where there certainly
// is no BodyService; we will implement our own support.
//            BodyService(_client.requireService(BodyService)).setIdle(nowIdle);
        }
    }

    /**
     * Try to assign focus to the chat entry field if it seems like we should.
     */
    protected function checkChatFocus (... ignored) :void
    {
        try {
            var focus :Object = _stage.focus;
            if (!(focus is TextField) && !(focus is ChatCantStealFocus)) {
                ChatControl.grabFocus();
            }
        } catch (err :Error) {
            log.warning("Couldn't focus chat", err);
        }
    }

    protected const _client :LocusClient = inject(LocusClient);

    protected const _stage :Stage = inject(Stage);
    protected const _topPanel :TopPanel = inject(TopPanel);

    /** A special logoff message to use when we disconnect. */
    protected var _logoffMessage :String;

    /** Whether we think we're idle or not. */
    protected var _idle :Boolean;

    /** A timer to watch our idleness. */
    protected var _idleTimer :Timer;

    /** Used for idle tracking. */
    protected var _idleMousePoint :Point;

    protected var _idleStamp :Number;

    private static const log :Log = Log.getLog(LocusController);
}
}
