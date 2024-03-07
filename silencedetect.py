# required libraries
from pyAudioAnalysis import audioBasicIO as aIO
from pyAudioAnalysis import audioSegmentation as aS
import matplotlib.pyplot as plt
import os
import sys
import librosa
import wave

# escape codes for text color
GREEN = '\033[92m'
RED = '\033[91m'
YELLOW = '\033[93m'
RESET = '\033[0m'

def print_green(message):
    print(GREEN + message + RESET)

def print_red(message):
    print(RED + message + RESET)

def print_yellow(message):
    print(YELLOW + message + RESET)

def check_wav_header(wav_file):
    # Check if it's a file
    if not os.path.isfile(wav_file):
        print(f"Error: {os.path.basename(wav_file)} is not a file. Aborting...")
        sys.exit(1)

    try:
        # Open the WAV file using wave library
        with wave.open(wav_file, 'rb') as wav_obj:
            # Get the format information
            wave_format = wav_obj.getparams()

            # Check if it's a valid WAV file
            if wave_format.nchannels > 0 and wave_format.sampwidth > 0 and wave_format.framerate > 0:
                print_green(f"{os.path.basename(wav_file)}: WAV header is valid.")
                return True
            else:
                printre(f"Error: {os.path.basename(wav_file)} has an invalid WAV header. Aborting...")
                sys.exit(1)

    except wave.Error as e:
        print_red(f"Error: {os.path.basename(wav_file)} is not a valid WAV file. Aborting...")
        print_red("=============END=============")
        sys.exit(1)

def get_wav_info(wav_file):
    try:
        with wave.open(wav_file, 'rb') as wav_obj:
            sample_rate = wav_obj.getframerate()
            duration = wav_obj.getnframes() / float(sample_rate)
            return sample_rate, duration

    except Exception as e:
        print(f"Error getting information for {wav_file}: {str(e)}")
        return None, None

def process_audio_file(file_path, sil_time=0.020):
    try:
        # Extract the filename using os.path.basename()
        filename = os.path.basename(file_path)

        # Get the sample rate using the get_sample_rate function
        sample_rate, duration = get_wav_info(file_path)

        if sample_rate is None:
            # Handle the case where sample rate cannot be determined
            print_red(f"Error processing {filename}: Sample rate could not be determined.")
            return

        # read audio file and get active segments
        [Fs, x] = aIO.read_audio_file(file_path)
        segments = aS.silence_removal(x,
                                     Fs,
                                     0.020,
                                     0.020,
                                     smooth_window=1.0,
                                     weight=0.3,
                                     plot=False)  # Set plot to False to prevent double plotting

        # update segments with additional silence information
        updated_segments = update_segments(file_path, segments, sil_time)

        # Print the breakdown of silence portions
        print(f"Silence breakdown for {filename}:")
        for idx, segment in enumerate(updated_segments, start=1):
            print(f"Silence Portion {idx}: Start: {segment[0]}, End: {segment[1]}")

        # Extract information about the end of the first silence portion
        if len(updated_segments) > 0:
            end_of_first_silence = updated_segments[0][1]
            end_of_first_silence_timecode = get_timecode(end_of_first_silence)
            end_of_first_silence_sample = int(end_of_first_silence * sample_rate)
            print_green(f"[IN]: {end_of_first_silence_timecode} ({end_of_first_silence_sample})")

        # Extract information about the start of the last silence portion
        if len(updated_segments) > 1:
            start_of_last_silence = updated_segments[-1][0]
            start_of_last_silence_timecode = get_timecode(start_of_last_silence)
            start_of_last_silence_sample = int(start_of_last_silence * sample_rate)
            print_green(f"[OUT]: {start_of_last_silence_timecode} ({start_of_last_silence_sample})")
            duration_timecode = get_timecode(duration)
            print_green(f"[DURATION]: {duration_timecode}")

        # Write silence portions to a text file
        write_silence_to_txt(filename, updated_segments)

        # Set figure size to make the graph bigger on the x-axis
        plt.figure(figsize=(30, 10))  # You can adjust the width and height as needed

        # plot the audio file with the updated segments
        plt.plot(x)
        plt.title(f"Audio File with Silence Removal ({filename})")

        # mark the silent segments on the plot
        for segment in updated_segments:
            plt.axvspan(segment[0] * Fs, segment[1] * Fs, color='red', alpha=0.3)

        plt.xlabel("Time (s)")
        plt.ylabel("Amplitude")
        output_file = f"{filename}_plot_with_silence.png"
        plt.savefig(output_file)
        plt.close()
        print_green(f"Processed {filename}. Plot saved as {output_file}")

    except Exception as e:
        print_red(f"Error processing {filename}: {str(e)}")

def get_timecode(input_seconds):
    # calculate hours, minutes, and seconds
    hours = int(input_seconds // 3600)
    minutes = int((input_seconds % 3600) // 60)
    seconds = input_seconds % 60

    # format the result
    return f"{hours:02d}:{minutes:02d}:{seconds:05.2f}"

def update_segments(filename, segments, sil_time):
    ans = []
    tmp = 0
    n = len(segments)
    for idx, t in enumerate(segments):
        if t[0] - tmp >= sil_time:
            ans.append((tmp, t[0]))
        tmp = t[1]
        if idx == n-1:
            fn = librosa.get_duration(path=filename)  # Use 'path' instead of 'filename'
            if fn - tmp >= sil_time:
                ans.append((tmp, fn))
    return ans

def write_silence_to_txt(filename, silence_portions):
    output_file = f"{filename}_silence_portions.txt"
    with open(output_file, 'w') as file:
        file.write(f"Silence breakdown for {filename}:\n")
        for idx, portion in enumerate(silence_portions, start=1):
            file.write(f"Silence Portion {idx}: Start: {portion[0]}, End: {portion[1]}\n")
    print_green(f"Silence portions saved to {output_file}")

def generate_xml(in_point, out_point, sample_rate):
    xml_template = f"""<Cues samplerate="{sample_rate}">
    <Cue>
        <ID>1</ID>
        <Position>{in_point}</Position>
        <DataChunkID>0x64617461</DataChunkID>
        <ChunkStart>0</ChunkStart>
        <BlockStart>0</BlockStart>
        <SampleOffset>130242</SampleOffset>
        <Label>Presentation</Label>
        <Note></Note>
        <LabeledText>
            <SampleLength>{out_point - in_point}</SampleLength>
            <PurposeID>0x72676E20</PurposeID>
            <Country>0</Country>
            <Language>0</Language>
            <Dialect>0</Dialect>
            <CodePage>0</CodePage>
            <Text></Text>
        </LabeledText>
    </Cue>
</Cues>
"""
    return xml_template

if __name__ == "__main__":
    # check if file paths are provided as command-line arguments
    if len(sys.argv) < 2:
        print_yellow("Usage: python3 script.py [file1.wav] [file2.wav] [file3.wav] ...")
        sys.exit(1)

    # iterate through provided file paths and process each audio file
    for file_path in sys.argv[1:]:
        filename = os.path.basename(file_path)
        print_green(f"============{filename}============")
        check_wav_header(file_path)
        process_audio_file(file_path)
        print_green("=============END=============")
