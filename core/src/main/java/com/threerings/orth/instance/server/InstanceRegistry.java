//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

package com.threerings.orth.instance.server;

import java.util.Map;

import com.google.common.collect.Maps;
import com.google.inject.Singleton;
import com.google.inject.internal.Preconditions;

import com.threerings.orth.instance.data.Instance;

import static com.threerings.orth.Log.log;

@Singleton
public class InstanceRegistry
{
    public Instance getInstance (String instanceId)
    {
        return _instances.get(instanceId);
    }

    /**
     * Register an {@link Instance} locally and on the peer nodes.
     */
    public void registerInstance (Instance instance)
    {
        Preconditions.checkState(!_instances.containsKey(instance.getInstanceId()),
            "Instance '%s' already registered", instance.getInstanceId());
        _instances.put(instance.getInstanceId(), instance);
        log.debug("Registered local instance", "instance", instance);
    }

    protected Map<String, Instance> _instances = Maps.newHashMap();
}
