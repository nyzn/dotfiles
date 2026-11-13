# Cutout transition: subjects of clip B appear as cutouts over the end of clip A, then B's background pops in.
import cv2,numpy as np,subprocess,sys
from rembg import new_session, remove
A,B,N,OUT=sys.argv[1],sys.argv[2],int(sys.argv[3]),sys.argv[4]
FPS="30000/1001"
W,H=map(int,subprocess.run(["ffprobe","-v","error","-select_streams","v:0","-show_entries","stream=width,height","-of","csv=p=0",A],capture_output=True,text=True).stdout.strip().split(","))
def nframes(p): return int(subprocess.run(["ffprobe","-v","error","-count_frames","-select_streams","v:0","-show_entries","stream=nb_read_frames","-of","csv=p=0",p],capture_output=True,text=True).stdout.strip())
def read(p,start,n):
    r=subprocess.run(["ffmpeg","-v","error","-i",p,"-vf",f"trim=start_frame={start}:end_frame={start+n},setpts=PTS-STARTPTS","-pix_fmt","bgr24","-f","rawvideo","-"],capture_output=True)
    return np.frombuffer(r.stdout,np.uint8).reshape(-1,H,W,3)
na=nframes(A); fa=read(A,na-N,N); fb=read(B,0,N); ses=new_session("u2net_human_seg")
enc=subprocess.Popen(["ffmpeg","-v","error","-y","-f","rawvideo","-pix_fmt","bgr24","-s",f"{W}x{H}","-r",FPS,"-i","-","-ss",f"{(na-N)*1001/30000:.4f}","-i",A,
   "-map","0:v","-map","1:a","-c:v","libx264","-preset","medium","-crf","17","-profile:v","high","-pix_fmt","yuv420p","-c:a","aac","-b:a","192k","-ac","2","-ar","48000","-shortest",OUT+"_x.mp4"],stdin=subprocess.PIPE)
k=cv2.getStructuringElement(cv2.MORPH_ELLIPSE,(15,15))
for i in range(N):
    m=np.array(remove(cv2.cvtColor(fb[i],cv2.COLOR_BGR2RGB),session=ses,only_mask=True))
    m=cv2.GaussianBlur(m,(0,0),2); _,hard=cv2.threshold(m,110,255,cv2.THRESH_BINARY)
    ring=cv2.GaussianBlur(cv2.dilate(hard,k),(0,0),1.5).astype(np.float32)/255
    a=m.astype(np.float32)/255
    fg=fb[i].astype(np.float32)
    # pop-in: cutout scales 1.18 -> 1.0 over the first 5 frames
    s=1+0.18*max(0,1-i/5)**2
    if s>1.001:
        M=cv2.getRotationMatrix2D((W/2,H*0.55),0,s)
        fg=cv2.warpAffine(fg,M,(W,H)); a=cv2.warpAffine(a,M,(W,H)); ring=cv2.warpAffine(ring,M,(W,H))
    op=min(1,(i+1)/3)
    bg=fa[i].astype(np.float32)*(1-0.35*min(1,i/4))        # dim clip A under the cutout
    out=bg*(1-ring[...,None]*op)+255*ring[...,None]*op      # white outline
    out=out*(1-a[...,None]*op)+fg*a[...,None]*op
    enc.stdin.write(np.clip(out,0,255).astype(np.uint8).tobytes())
enc.stdin.close(); enc.wait()
ta=(na-N)*1001/30000; tb=N*1001/30000
subprocess.run(["ffmpeg","-v","error","-y","-i",A,"-t",f"{ta:.4f}","-c:v","libx264","-preset","medium","-crf","17","-profile:v","high","-pix_fmt","yuv420p","-c:a","aac","-b:a","192k","-ar","48000",OUT+"_a.mp4"],check=True)
subprocess.run(["ffmpeg","-v","error","-y","-ss",f"{tb:.4f}","-i",B,"-vf","fade=t=in:d=0.14:color=white","-c:v","libx264","-preset","medium","-crf","17","-profile:v","high","-pix_fmt","yuv420p","-c:a","aac","-b:a","192k","-ar","48000",OUT+"_b.mp4"],check=True)
