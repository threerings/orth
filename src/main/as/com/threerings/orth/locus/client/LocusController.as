//
// $Id: LocusController.as 19431 2010-10-22 22:08:36Z zell $

package com.threerings.orth.locus.client {
import flash.display.DisplayObject;
import flash.events.Event;
import flash.events.IEventDispatcher;
import flash.events.TimerEvent;
import flash.geom.Point;
import flash.utils.Timer;
import flash.utils.getTimer;

import flashx.funk.ioc.inject;

import com.threerings.crowd.chat.data.ChatCodes;
import com.threerings.crowd.data.CrowdCodes;

import com.threerings.util.Controller;
import com.threerings.util.Log;

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

        // create a timer to poll mouse position and track timing
        _idleTimer = new Timer(1000);
        _idleTimer.addEventListener(TimerEvent.TIMER, handlePollIdleMouse);

        setControlledPanel(_topPanel.root);
    }

    /**
     * Are we currently idle, i.e. no input for a period of time? This precludes away-ness.
     */
    public function isIdle () :Boolean
    {
        return _idle;
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

    protected const _client :LocusClient = inject(LocusClient);

    protected const _topPanel :TopPanel = inject(TopPanel);

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
