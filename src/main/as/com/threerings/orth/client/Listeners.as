//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

package com.threerings.orth.client {
import com.threerings.orth.chat.client.OrthChatDirector;

import flashx.funk.ioc.Module;

import com.threerings.util.Log;
import com.threerings.util.MessageBundle;

import com.threerings.presents.client.ConfirmAdapter;
import com.threerings.presents.client.InvocationAdapter;
import com.threerings.presents.client.InvocationService_ConfirmListener;
import com.threerings.presents.client.InvocationService_InvocationListener;
import com.threerings.presents.client.InvocationService_ResultListener;
import com.threerings.presents.client.ResultAdapter;

import com.threerings.orth.chat.client.OrthChatDirector;
import com.threerings.orth.data.OrthCodes;

public class Listeners
{
    public static function init (module :Module) :void
    {
        _module = module;
    }

    public static function listener (bundle :String = null,
        errWrap :String = null, ... logArgs) :InvocationService_InvocationListener
    {
        return new InvocationAdapter(chatErrHandler(bundle, errWrap, logArgs));
    }

    public static function confirmListener (bundle :String = null,
        confirm :* = null, errWrap :String = null, ... logArgs)
        :InvocationService_ConfirmListener
    {
        var success :Function = function () :void {
            if (confirm is Function) {
                (confirm as Function)();
            } else if (confirm is String) {
                displayFeedback(bundle, String(confirm));
            }
        };
        return new ConfirmAdapter(success, chatErrHandler(bundle, errWrap, logArgs));
    }

    public static function resultListener (gotResult :Function,
        bundle :String = null, errWrap :String = null, ... logArgs)
        :InvocationService_ResultListener
    {
        return new ResultAdapter(gotResult, chatErrHandler(bundle, errWrap, logArgs));
    }

    /**
     * Create an error handling function for use with InvocationService listener adapters.
     */
    public static function chatErrHandler (
        bundle :String, errWrap :String=null, ...logArgs) :Function
    {
        return function (cause :String) :void {
            var args :Array = logArgs.slice();
            args.splice(0, 0, bundle, cause, errWrap);
            displayError.apply(null, args);
        };
    }

    // from OrthContext
    public static function displayFeedback (bundle :String, message :String) :void
    {
        if (bundle == null) {
            bundle = OrthCodes.GENERAL_MSGS;
        }
        OrthChatDirector(_module.getInstance(OrthChatDirector)).displayFeedback(bundle, message);
    }

    public static function displayError (bundle :String, cause :String,
        errWrap :String=null, ...logArgs) :void
    {
        if (bundle == null) {
            bundle = OrthCodes.GENERAL_MSGS;
        }
        var args :Array = logArgs.concat("cause", cause); // make a copy, we're reentrant
        if (args.length % 2 == 0) {
            args.unshift("Reporting failure");
        }
        log.info.apply(null, args);

        if (errWrap != null) {
            cause = MessageBundle.compose(errWrap, cause);
        }
        displayFeedback(bundle, cause);
    }

    protected static var _module :Module;
    protected static const log :Log = Log.getLog(Listeners);
}
}
