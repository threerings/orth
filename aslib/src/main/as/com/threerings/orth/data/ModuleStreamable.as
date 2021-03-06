//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

// GENERATED PREAMBLE START
package com.threerings.orth.data {

import flashx.funk.ioc.Module;

import com.threerings.io.ObjectInputStream;
import com.threerings.io.SimpleStreamableObject;

import com.threerings.orth.aether.client.AetherClient;

// GENERATED PREAMBLE END

// GENERATED CLASSDECL START
public class ModuleStreamable extends SimpleStreamableObject
{
// GENERATED CLASSDECL END

// GENERATED STREAMING DISABLED
    override public function readObject (ins :ObjectInputStream) :void
    {
        _module = ins.getClientProperty(AetherClient.MODULE_PROP_NAME);
        super.readObject(ins);
    }

    protected /* transient */ var _module :Module;

// GENERATED CLASSFINISH START
}
}
// GENERATED CLASSFINISH END

