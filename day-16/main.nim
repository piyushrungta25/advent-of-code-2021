include ../imports

type
    BinaryStream = iterator(numBits: int): string

    PacketType = enum
        Literal, Operator

    Packet = object
        version: int
        typeID: int
        case packetType: PacketType
            of Literal:
                value: int
            of Operator:
                values: seq[Packet]


# forward declarations
proc parseNext(stream: BinaryStream): Packet
proc parse(stream: BinaryStream): seq[Packet]
proc parseOperator(stream: BinaryStream): Packet
proc parseLiteral(stream: BinaryStream): Packet


proc toBinaryString(str: string): string =
    for c in str:
        result &= ($c).parseHexInt.toBin(4)


proc getBitStream(binaryString: string): BinaryStream =
    var curPos = 0
    return iterator(numBits: int): string =
        while true:
            if curPos + numBits > binaryString.len: break
            let res = $(binaryString[curPos..<(curPos + numBits)])
            curPos += numBits
            yield res

        raise newException(ValueError, "no more bits")


proc parseLiteral(stream: BinaryStream): Packet =
    var
        valueStr: string
        hasMore = true

    while hasMore:
        hasMore = stream(1) == "1"
        valueStr &= stream(4)

    return Packet(packetType: Literal, value: valueStr.parseBinInt)


proc parseOperator(stream: BinaryStream): Packet =
    var subPackets: seq[Packet]
    let lengthTypeId = stream(1)

    if lengthTypeId == "0":
        let length = stream(15).parseBinInt
        subpackets = parse(getBitStream(stream(length)))
    else:
        let length = stream(11).parseBinInt
        subPackets = collect(for i in 1..length: parseNext(stream))

    return Packet(packetType: Operator, values: subPackets)


proc parseNext(stream: BinaryStream): Packet =
    var packet: Packet
    let version = stream(3).parseBinInt
    let typeID = stream(3).parseBinInt
    case typeID:
        of 4:
            packet = parseLiteral(stream)
        else:
            packet = parseOperator(stream)

    packet.typeID = typeID
    packet.version = version
    return packet


proc parse(stream: BinaryStream): seq[Packet] =
    while true:
        try: result.add(stream.parseNext)
        except ValueError: break


proc sumVersion(packet: Packet): int =
    case packet.packetType:
        of Literal:
            return packet.version
        of Operator:
            return packet.version + packet.values.map(sumVersion).sum


proc eval(packet: Packet): int =
    case packet.packetType:
        of Literal:
            return packet.value
        of Operator:
            let operands = packet.values.map(eval)
            case packet.typeID:
                of 0: return operands.sum
                of 1: return operands.foldl(a * b)
                of 2: return operands.min
                of 3: return operands.max
                of 5: return ord(operands[0] > operands[1])
                of 6: return ord(operands[0] < operands[1])
                of 7: return ord(operands[0] == operands[1])
                else: raise newException(ValueError, "shouldn't happen")


when isMainModule:
    let hex = "input".readFile.strip
    let packet = hex.toBinaryString.getBitStream.parseNext
    echo packet.sumVersion
    echo packet.eval
