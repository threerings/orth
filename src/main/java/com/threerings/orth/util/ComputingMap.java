//
// Who - Copyright 2010-2011 Three Rings Design, Inc.

package com.threerings.orth.util;

import java.util.List;
import java.util.Map;

import com.google.common.base.Function;
import com.google.common.base.Supplier;
import com.google.common.collect.ForwardingMap;
import com.google.common.collect.Lists;
import com.google.common.collect.Maps;

/**
 * A forwarding map that never returns null from {@link Map#get()}, but instead computes a new
 * value for the requested key. The creation of the value is delegated to subclasses using the
 * {@link ComputingMap#compute()} method.
 */
public abstract class ComputingMap<K, V> extends ForwardingMap<K, V>
{
    /**
     * Creates a new map that forwards to a {@link HashMap} and computes values for missing keys
     * using a function.
     * @param function computes the value for a missing key
     */
    public static <K, V> Map<K, V> create (Function<K, V> function)
    {
        Map<K, V> delegate = Maps.newHashMap();
        return create(delegate, function);
    }

    /**
     * Creates a new map that forwards to a supplied map and computes values for missing key
     * using a function.
     * @param function computes the value for a missing key
     */
    public static <K, V> Map<K, V> create (Map<K, V> delegate, final Function<K, V> function)
    {
        return new ComputingMap<K, V>(delegate) {
            @Override protected V compute (K key) {
                return function.apply(key);
            }
        };
    }

    /**
     * Creates a new map that forwards to a {@link HashMap} and computes values for missing keys
     * using a supplier.
     * @param supplier returns the value to use when a key is missing
     */
    public static <K, V> Map<K, V> create (Supplier<V> supplier)
    {
        Map<K, V> delegate = Maps.newHashMap();
        return create(delegate, supplier);
    }

    /**
     * Creates a new map that forwards to a supplied map and computes values for missing keys
     * using a supplier.
     * @param supplier returns the value to use when a key is missing
     */
    public static <K, V> Map<K, V> create (Map<K, V> delegate, final Supplier<V> supplier)
    {
        return new ComputingMap<K, V>(delegate) {
            @Override protected V compute (K key) {
                return supplier.get();
            }
        };
    }

    /**
     * Creates a new map that forwards to a {@link HashMap} and uses a constant value for missing
     * keys.
     * @param constant value to assign when a key is missing
     */
    public static <K, V> Map<K, V> create (V constant)
    {
        Map<K, V> delegate = Maps.newHashMap();
        return create(delegate, constant);
    }

    /**
     * Creates a new map that forwards to a supplied map and uses a constant value for missing
     * keys.
     * @param constant value to assign when a key is missing
     */
    public static <K, V> Map<K, V> create (Map<K, V> delegate, final V constant)
    {
        return create(delegate, new Supplier<V>() {
            public V get () {
                return constant;
            }
        });
    }

    /**
     * Creates a new list-valued map that forwards to a {@link HashMap} and uses a new array list
     * when a key is missing.
     */
    public static <K, T> Map<K, List<T>> withArrayListValues ()
    {
        Supplier<List<T>> supplier = new Supplier<List<T>>() {
            @Override public List<T> get () {
                return Lists.newArrayList();
            }
        };
        return create(supplier);
    }

    /**
     * Creates a new computing map that forwards to a hash map.
     */
    public ComputingMap ()
    {
        _delegate = Maps.newHashMap();
    }

    /**
     * Creates a new computing map that forwards to a supplied map.
     */
    public ComputingMap (Map<K, V> delegate)
    {
        _delegate = delegate;
    }

    @Override public V get (Object obj)
    {
        @SuppressWarnings("unchecked")
        K key = (K)obj;
        V v  = super.get(key);
        if (v == null) {
            v = compute(key);
            if (v == null) {
                throw new RuntimeException("Null computed map value");
            }
            put(key, v);
        }
        return v;
    }

    @Override protected Map<K, V> delegate ()
    {
        return _delegate;
    }

    /**
     * Returns the value to use when a key is missing. May not return null. If null is returned,
     * {@link #get()} will throw a runtime exception.
     */
    abstract protected V compute (K key);

    protected Map<K, V> _delegate;
}
