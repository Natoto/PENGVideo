package sfc.network.req;

import java.io.ByteArrayOutputStream;
import java.io.DataInputStream;
import java.io.DataOutputStream;
import java.util.Arrays;

import sfc.network.Req;

public class PureData implements Req {
	public static final int ProtocolId = 0x1008;

	private byte[] data;

	public byte[] getData() {
		return data;
	}

	public void setData(byte[] data) {
		this.data = data;
	}

	@Override
	public int getProtocolId() {
		return ProtocolId;
	}

	@Override
	public void fromDis(DataInputStream dis) {
		try {
			int len = dis.readInt();
			data = new byte[len];
			dis.read(data);
		} catch (Exception e) {
			e.printStackTrace();
		}
	}

	@Override
	public byte[] toByteArray() {
		ByteArrayOutputStream baos = new ByteArrayOutputStream();
		DataOutputStream dos = new DataOutputStream(baos);
		try{
			dos.writeInt(data.length);
			dos.write(data);
		}catch(Exception e){
			e.printStackTrace();
		}
		return baos.toByteArray();
	}

	@Override
	public String toString() {
		String dataDec = (data==null||data.length<2)?"TooShort":data[0]+"-"+data[data.length-1];
		return "PureData [data=" + dataDec + "]";
	}

}
