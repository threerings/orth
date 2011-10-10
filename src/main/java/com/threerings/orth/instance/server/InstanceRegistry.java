//
// Who - Copyright 2010-2011 Three Rings Design, Inc.

package com.threerings.orth.instance.server;

import java.util.Map;

import com.google.inject.Inject;
import com.google.inject.Injector;
import com.google.inject.Singleton;
import com.google.inject.internal.Maps;

import com.threerings.orth.instance.server.Instance.InstanceVisitor;

import static com.threerings.orth.Log.log;

@Singleton
public class InstanceRegistry
{
    public Instance getInstance (InstanceVisitor visitor)
    {
        InstanceLocal local = visitor.asBody().getLocal(InstanceLocal.class);
        if (local == null) {
            local = new InstanceLocal();
            visitor.asBody().setLocal(InstanceLocal.class, local);
        }
        return local.instance;
    }

    public Instance getInstance (String instanceId)
    {
        return _instances.get(instanceId);
    }

    // TODO: how does this fit with Instance subclassing? probably drop.
    public Instance createInstance (String instanceId)
    {
        Instance instance = new Instance(instanceId);
        _injector.injectMembers(instance);
        registerInstance(instance);
        return instance;
    }

    public void registerInstance (Instance instance)
    {
        _instances.put(instance.getInstanceId(), instance);
    }

    protected Map<String, Instance> _instances = Maps.newHashMap();

    @Inject protected Injector _injector;
}
