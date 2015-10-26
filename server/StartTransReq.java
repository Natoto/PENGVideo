package sfc.network.req;

import java.io.ByteArrayOutputStream;
import java.io.DataInputStream;
import java.io.DataOutputStream;
import java.util.HashMap;
import java.util.Map;
import java.util.logging.Level;

import sfc.network.Req;

/**
 * 开启传输
 * 
 * @author mcintype
 *
 */
public class StartTransReq implements Req {
	public static final int ProtocolId = 0x1001;

	// 附加信息，用于扩展
	private Map<String, String> meta;0000 0000

	// 文件原始的名字，不带后缀
	private String oriFileName; len+value

	// 文件原始的名称后缀，不带点号
	private String oriFileType;  len+value

	// 待传输文件的总大小，以字节为单位
	private int dataLenInBytes; 32

	@Override
	public void fromDis(DataInputStream dis) {
		try {
			int cnt = dis.readInt();
			meta = new HashMap<String,String>();
			String key = null;
			String val = null;
			for(int i=0;i<cnt;i++){
				key = dis.readUTF();
				val = dis.readUTF();
				meta.put(key, val);
			}
			oriFileName = dis.readUTF();
			oriFileType = dis.readUTF();
			dataLenInBytes = dis.readInt();
		} catch (Exception e) {
			e.printStackTrace();
		}
	}
	
	@Override
	public byte[] toByteArray() {
		ByteArrayOutputStream baos = new ByteArrayOutputStream();
		DataOutputStream dos = new DataOutputStream(baos);
		
		try{
			if(meta==null){
				dos.writeInt(0);
			}else{
				dos.writeInt(meta.size());
				for(String k:meta.keySet()){
					dos.writeUTF(k);
					dos.writeUTF(meta.get(k));
				}
			}
			
			dos.writeUTF(oriFileName);
			dos.writeUTF(oriFileType);
			dos.writeInt(dataLenInBytes);
			
			return baos.toByteArray();
		}catch(Exception e){
			e.printStackTrace();
			return null;
		}finally{
			try{
				dos.close();
				baos.close();
			}catch(Exception ex){
				ex.printStackTrace();
			}
		}
		
	}
	
	public Map<String, String> getMeta() {
		return meta;
	}

	public void setMeta(Map<String, String> meta) {
		this.meta = meta;
	}

	public String getOriFileName() {
		return oriFileName;
	}

	public void setOriFileName(String oriFileName) {
		this.oriFileName = oriFileName;
	}

	public String getOriFileType() {
		return oriFileType;
	}

	public void setOriFileType(String oriFileType) {
		this.oriFileType = oriFileType;
	}

	public int getDataLenInBytes() {
		return dataLenInBytes;
	}

	public void setDataLenInBytes(int dataLenInBytes) {
		this.dataLenInBytes = dataLenInBytes;
	}

	@Override
	public int getProtocolId() {
		return ProtocolId;
	}

	@Override
	public String toString() {
		return "StartTransReq [meta=" + meta + ", oriFileName=" + oriFileName
				+ ", oriFileType=" + oriFileType + ", dataLenInBytes="
				+ dataLenInBytes + "]";
	}

}
