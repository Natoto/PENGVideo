package sfc.network.resp;

import java.io.ByteArrayOutputStream;
import java.io.DataInputStream;
import java.io.DataOutputStream;
import java.util.logging.Level;

import sfc.network.Resp;

public class ProgressNotice implements Resp{
	public static final int ProtocolId = 0x2005;
	
	// 传输的id编号，成功时才有意义
	private int transId;
	// 成功传输的大小，字节为单位
	private int transLenInBytes;
	// 总大小，字节为单位
	private int totalLenInBytes;

	@Override
	public byte[] toByteArray() {
		ByteArrayOutputStream bais = new ByteArrayOutputStream();
		DataOutputStream dis = new DataOutputStream(bais);
		
		try{
			dis.writeInt(transId);
			dis.writeInt(transLenInBytes);
			dis.writeInt(totalLenInBytes);
			
			dis.flush();
			return bais.toByteArray();
		}catch(Exception e){
			e.printStackTrace();
			return null;
		}finally{
			try{
				dis.close();
				bais.close();
			}catch(Exception ex){
				ex.printStackTrace();
			}
		}
	}

	@Override
	public void fromDis(DataInputStream dis) {
		try{
			transId = dis.readInt();
			transLenInBytes = dis.readInt();
			totalLenInBytes = dis.readInt();
		}catch(Exception e){
			e.printStackTrace();
		}
		
	}
	
	public int getTransId() {
		return transId;
	}

	public void setTransId(int transId) {
		this.transId = transId;
	}

	public int getTransLenInBytes() {
		return transLenInBytes;
	}

	public void setTransLenInBytes(int transLenInBytes) {
		this.transLenInBytes = transLenInBytes;
	}

	public int getTotalLenInBytes() {
		return totalLenInBytes;
	}

	public void setTotalLenInBytes(int totalLenInBytes) {
		this.totalLenInBytes = totalLenInBytes;
	}
	
	@Override
	public int getProtocolId() {
		return ProtocolId;
	}

	@Override
	public String toString() {
		return "ProgressNotice [transId=" + transId + ", transLenInBytes="
				+ transLenInBytes + ", totalLenInBytes=" + totalLenInBytes
				+ "]";
	}

}
