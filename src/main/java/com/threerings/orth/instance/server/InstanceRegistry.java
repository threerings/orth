//
// Who - Copyright 2010-2011 Three Rings Design, Inc.

package com.threerings.orth.instance.server;

import java.util.Map;

import com.google.common.collect.Maps;
import com.google.inject.Inject;
import com.google.inject.Injector;
import com.google.inject.Singleton;
import com.google.inject.internal.Preconditions;

import com.threerings.crowd.server.BodyLocator;

import com.threerings.whirled.spot.server.SpotSceneRegistry;

import com.threerings.orth.instance.data.Instance;
import com.threerings.orth.instance.data.InstanceInfo;
import com.threerings.orth.peer.server.OrthPeerManager;

import static com.threerings.orth.Log.log;

@Singleton
public class InstanceRegistry
{
    @Inject public InstanceRegistry (SpotSceneRegistry reg)
    {
        Preconditions.checkState(reg instanceof InstancingSceneRegistry,
            "Failing: SpotSceneRegistry must be bound to InstancingSceneRegistry.");
    }

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

        // NOTE: This does no locking or coordination between peers. It's purely informative.
        InstanceInfo info = new InstanceInfo(instance.getInstanceId());
        if (_peerman.getOrthNodeObject().instances.contains(info)) {
            log.warning("InstanceInfo already registered on OrthNodeObject",
                "instance", instance.getInstanceId());
        } else {
            _peerman.getOrthNodeObject().addToInstances(info);
        }
    }

    protected Map<String, Instance> _instances = Maps.newHashMap();

    @Inject protected Injector _injector;
    @Inject protected BodyLocator _locator;
    @Inject protected OrthPeerManager _peerman;
}
