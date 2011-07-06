//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.

package com.threerings.orth.chat.data {

import com.threerings.crowd.chat.data.ChatChannel;
import com.threerings.crowd.chat.data.ChatCodes;

import com.threerings.io.ObjectInputStream;
import com.threerings.io.ObjectOutputStream;

import com.threerings.util.Log;
import com.threerings.util.Name;
import com.threerings.util.StringUtil;

import com.threerings.orth.data.ChannelName;
import com.threerings.orth.data.PlayerName;
import com.threerings.orth.room.data.RoomName;

/**
 * Defines a particular chat channel.
 */
public class OrthChatChannel extends ChatChannel
{
    /** A chat channel between two players. Implemented using tells. */
    public static const MEMBER_CHANNEL :int = 1;

    /** A chat channel created by a player into whom they invite other players. */
    public static const PRIVATE_CHANNEL :int = 3;

    /** A chat channel for room chat. */
    public static const ROOM_CHANNEL :int = 4;

    /** The type of this chat channel. */
    public var type :int;

    /** The name that identifies this channel (either a {@link OrthName}, {@link GroupName},
     * {@link ChannelName}, or {@link JabberName}. */
    public var ident :Name;

    /**
     * Creates a channel identifier for a channel communicating with the specified member.
     */
    public static function makeMemberChannel (member :PlayerName) :OrthChatChannel
    {
        return new OrthChatChannel(MEMBER_CHANNEL, member);
    }

    /**
     * Creates a channel identifier for the specified named private channel.
     */
    public static function makePrivateChannel (channel :ChannelName) :OrthChatChannel
    {
        return new OrthChatChannel(PRIVATE_CHANNEL, channel);
    }

    /**
     * Creates a channel identifier for the specified room.
     */
    public static function makeRoomChannel (room :RoomName) :OrthChatChannel
    {
        return new OrthChatChannel(ROOM_CHANNEL, room);
    }

    /**
     * Returns the static type of the given localType.
     */
    public static function typeOf (localtype :String) :int
    {
        if (localtype == null) {
            log.warning("asked to determine typeOf a null localtype");
            return -1;
        }

        if (localtype == ChatCodes.PLACE_CHAT_TYPE) {
            return ROOM_CHANNEL;
        }

        try {
            return StringUtil.parseInteger(localtype.charAt(0));
        } catch (err :ArgumentError) {
            // NOOP, fall through to -1
        }

        return -1;
    }

    /**
     * Returns the extra info stored after the type parameter.
     */
    public static function infoOf (localtype :String) :String
    {
        return (localtype.charAt(1) == ':') ? localtype.substring(2) : "";
    }

    /**
     * Returns true if the localType matches a room channel with the given scene id.
     */
    public static function typeIsForRoom (localType :String) :Boolean
    {
        return localType == ChatCodes.PLACE_CHAT_TYPE;
    }

    public function OrthChatChannel (type :int = 0, ident :Name = null)
    {
        this.type = type;
        this.ident = ident;
    }

    /**
     * Returns a string we can use to register this channel with the ChatDirector.
     */
    public function toLocalType () :String
    {
        return (type == ROOM_CHANNEL) ? ChatCodes.PLACE_CHAT_TYPE : (type + ":" + getId(ident));
    }

    /**
     * Are we able to speak on this channel?
     */
    public function isSpeakable () :Boolean
    {
        switch (type) {
        case ROOM_CHANNEL:
            return (RoomName(ident).getSceneId() != 0);

        default:
            return true;
        }
    }

    // from ChatChannel
    override public function compareTo (other :Object) :int
    {
        return StringUtil.compare(toString(), other.toString());
    }

    // from ChatChannel
    override public function hashCode () :int
    {
        return type ^ ident.hashCode();
    }

    // from Object
    override public function toString () :String
    {
        return toLocalType();
    }

    // from interface Streamable
    override public function readObject (ins :ObjectInputStream) :void
    {
        super.readObject(ins);
        type = ins.readInt();
        ident = Name(ins.readObject());
    }

    // from interface Streamable
    override public function writeObject (out :ObjectOutputStream) :void
    {
        super.writeObject(out);
        out.writeInt(type);
        out.writeObject(ident);
    }

    protected static function getId (name :Name) :String
    {
        if (name is PlayerName) {
            return "" + PlayerName(name).id;

        } else if (name is RoomName) {
            return "" + (name as RoomName).getSceneId();

        } else if (name is ChannelName) {
            var channelName :ChannelName = name as ChannelName;
            return channelName.getCreatorId() + ":" + channelName;

        } else {
            log.warning("ChatChannel unable to determine id!", "name", name);
            return null;
        }
    }

    private static const log :Log = Log.getLog(ChatChannel);
}
}
