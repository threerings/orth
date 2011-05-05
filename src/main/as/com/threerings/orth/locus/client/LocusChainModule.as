//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.
package com.threerings.orth.locus.client {

import flashx.funk.ioc.ChainModule;

import com.threerings.orth.client.OrthModule;

/**
 * Simply extend ChainModule and implement LocusModule.
 */
public class LocusChainModule extends ChainModule
    implements LocusModule
{
    public function LocusChainModule (oMod :OrthModule, wMod :AbstractLocusModule)
    {
        super(wMod, oMod);
    }
}
}
