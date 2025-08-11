/**
 * Fetches all videos from a YouTube channel and exports data to CSV
 * Requires a YouTube Data API v3 key
 */

const fs = require('fs');
const readline = require('readline');

class YouTubeChannelFetcher {
    constructor(apiKey) {
        this.apiKey = apiKey;
        this.baseUrl = 'https://www.googleapis.com/youtube/v3';
    }

    async fetchJson(url) {
        const response = await fetch(url);
        if (!response.ok) {
            throw new Error(`HTTP error! status: ${response.status}`);
        }
        return response.json();
    }

    async getChannelInfo(channelId) {
        const url = `${this.baseUrl}/channels?part=contentDetails,statistics&id=${channelId}&key=${this.apiKey}`;
        const data = await this.fetchJson(url);
        
        if (!data.items || data.items.length === 0) {
            throw new Error('Channel not found');
        }
        
        const channel = data.items[0];
        return {
            uploadsPlaylistId: channel.contentDetails.relatedPlaylists.uploads,
            videoCount: parseInt(channel.statistics.videoCount || '0'),
            subscriberCount: parseInt(channel.statistics.subscriberCount || '0'),
            viewCount: parseInt(channel.statistics.viewCount || '0')
        };
    }

    async getChannelUploadsPlaylistId(channelId) {
        const info = await this.getChannelInfo(channelId);
        return info.uploadsPlaylistId;
    }

    async getAllVideoIds(playlistId) {
        const videoIds = [];
        let nextPageToken = '';
        
        do {
            const params = new URLSearchParams({
                part: 'contentDetails',
                playlistId: playlistId,
                maxResults: '50',
                key: this.apiKey
            });
            
            if (nextPageToken) {
                params.append('pageToken', nextPageToken);
            }
            
            const url = `${this.baseUrl}/playlistItems?${params}`;
            const data = await this.fetchJson(url);
            
            if (data.items) {
                for (const item of data.items) {
                    videoIds.push(item.contentDetails.videoId);
                }
            }
            
            nextPageToken = data.nextPageToken || '';
        } while (nextPageToken);
        
        return videoIds;
    }

    async getVideoStats(videoIds) {
        const stats = [];
        
        for (let i = 0; i < videoIds.length; i += 50) {
            const idsSlice = videoIds.slice(i, i + 50);
            const params = new URLSearchParams({
                part: 'statistics,snippet',
                id: idsSlice.join(','),
                key: this.apiKey
            });
            
            const url = `${this.baseUrl}/videos?${params}`;
            const data = await this.fetchJson(url);
            
            if (data.items) {
                for (const item of data.items) {
                    stats.push({
                        video_id: item.id,
                        title: item.snippet.title,
                        views: parseInt(item.statistics.viewCount || '0'),
                        likes: parseInt(item.statistics.likeCount || '0'),
                        upload_date: item.snippet.publishedAt || ''
                    });
                }
            }
        }
        
        return stats;
    }

    calculateApiUsage(videoCount) {
        const playlistItemsCalls = Math.ceil(videoCount / 50);
        const videoDetailsCalls = Math.ceil(videoCount / 50);
        const totalCalls = 1 + playlistItemsCalls + videoDetailsCalls;
        const totalQuotaUnits = 1 + (playlistItemsCalls * 1) + (videoDetailsCalls * 1);
        
        return {
            totalApiCalls: totalCalls,
            totalQuotaUnits: totalQuotaUnits,
            estimatedTime: Math.ceil(totalCalls * 0.5)
        };
    }

    async getChannelEstimate(channelId) {
        console.log('Getting channel information...');
        const channelInfo = await this.getChannelInfo(channelId);
        const apiUsage = this.calculateApiUsage(channelInfo.videoCount);
        
        return {
            videoCount: channelInfo.videoCount,
            subscriberCount: channelInfo.subscriberCount,
            totalViews: channelInfo.viewCount,
            apiCalls: apiUsage.totalApiCalls,
            quotaUnits: apiUsage.totalQuotaUnits,
            estimatedTimeSeconds: apiUsage.estimatedTime
        };
    }

    formatAsCSV(videoStats) {
        const fetchDate = new Date().toISOString().replace('.000Z', 'Z');
        
        videoStats.sort((a, b) => new Date(a.upload_date) - new Date(b.upload_date));
        
        const headers = ['video_id', 'title', 'views', 'likes', 'upload_date', 'fetch_date'];
        const csvRows = [headers.join(',')];
        
        for (const video of videoStats) {
            const row = [
                video.video_id,
                `"${video.title.replace(/"/g, '""')}"`,
                video.views,
                video.likes,
                video.upload_date,
                fetchDate
            ];
            csvRows.push(row.join(','));
        }
        
        return csvRows.join('\n');
    }

    async fetchChannelData(channelId, outputFilename = 'youtube_data.csv', showEstimate = true) {
        try {
            if (showEstimate) {
                const estimate = await this.getChannelEstimate(channelId);
                console.log('\n=== CHANNEL ESTIMATE ===');
                console.log(`Videos: ${estimate.videoCount.toLocaleString()}`);
                console.log(`Subscribers: ${estimate.subscriberCount.toLocaleString()}`);
                console.log(`Total Views: ${estimate.totalViews.toLocaleString()}`);
                console.log(`\n=== API USAGE ESTIMATE ===`);
                console.log(`API Calls: ${estimate.apiCalls}`);
                console.log(`Quota Units: ${estimate.quotaUnits}`);
                console.log(`Estimated Time: ~${estimate.estimatedTimeSeconds} seconds`);
                console.log('========================\n');
                
                const readline = require('readline');
                const rl = readline.createInterface({
                    input: process.stdin,
                    output: process.stdout
                });
                
                await new Promise((resolve) => {
                    rl.question('Continue with data fetch? (y/N): ', (answer) => {
                        rl.close();
                        if (answer.toLowerCase() !== 'y' && answer.toLowerCase() !== 'yes') {
                            console.log('Operation cancelled.');
                            process.exit(0);
                        }
                        resolve();
                    });
                });
            }
            
            console.log('Getting channel uploads playlist...');
            const uploadsPlaylistId = await this.getChannelUploadsPlaylistId(channelId);
            
            console.log('Fetching all video IDs...');
            const videoIds = await this.getAllVideoIds(uploadsPlaylistId);
            console.log(`Found ${videoIds.length} videos`);
            
            console.log('Fetching video statistics...');
            const videoStats = await this.getVideoStats(videoIds);
            
            console.log('Generating CSV...');
            const csvData = this.formatAsCSV(videoStats);
            
            fs.writeFileSync(outputFilename, csvData);
            console.log(`Data exported to ${outputFilename}`);
            
            return videoStats;
        } catch (error) {
            console.error('Error fetching channel data:', error.message);
            throw error;
        }
    }
}

async function fetchYouTubeChannelData(apiKey, channelId, outputFilename = 'youtube_data.csv', showEstimate = true) {
    const fetcher = new YouTubeChannelFetcher(apiKey);
    return await fetcher.fetchChannelData(channelId, outputFilename, showEstimate);
}

async function getYouTubeChannelEstimate(apiKey, channelId) {
    const fetcher = new YouTubeChannelFetcher(apiKey);
    return await fetcher.getChannelEstimate(channelId);
}

async function promptForApiKey() {
    const rl = readline.createInterface({
        input: process.stdin,
        output: process.stdout
    });
    
    return new Promise((resolve) => {
        rl.stdoutMuted = true;
        rl.question('Enter your YouTube Data API key: ', (answer) => {
            rl.close();
            console.log(''); // Add newline after hidden input
            resolve(answer.trim());
        });
        
        rl._writeToOutput = function _writeToOutput(stringToWrite) {
            if (rl.stdoutMuted && stringToWrite !== '\n' && stringToWrite !== '\r\n') {
                rl.output.write('*');
            } else {
                rl.output.write(stringToWrite);
            }
        };
    });
}

function loadEnvFile() {
    try {
        const envPath = '.env';
        if (fs.existsSync(envPath)) {
            const envFile = fs.readFileSync(envPath, 'utf8');
            const lines = envFile.split('\n');
            
            for (const line of lines) {
                const trimmedLine = line.trim();
                if (trimmedLine && !trimmedLine.startsWith('#')) {
                    const [key, ...valueParts] = trimmedLine.split('=');
                    if (key && valueParts.length > 0) {
                        const value = valueParts.join('=').replace(/^["']|["']$/g, '');
                        process.env[key.trim()] = value;
                    }
                }
            }
        }
    } catch (error) {
        // Silently fail if .env file can't be read
    }
}

function getApiKeyFromEnv() {
    loadEnvFile(); // Load .env file first
    return process.env.YOUTUBE_API_KEY || process.env.YT_API_KEY;
}

module.exports = { YouTubeChannelFetcher, fetchYouTubeChannelData, getYouTubeChannelEstimate };

if (require.main === module) {
    const args = process.argv.slice(2);
    const command = args[0];
    
    if (!command || command === '--help' || command === '-h') {
        console.log(`YouTube Channel Data Fetcher
        
Usage:
  node fetchYouTubeData.js estimate <CHANNEL_ID>
    - Shows channel stats and API usage estimate only
    
  node fetchYouTubeData.js fetch <CHANNEL_ID> [output_file.csv]
    - Shows estimate and prompts to continue with full fetch
    
  node fetchYouTubeData.js fetch-direct <CHANNEL_ID> [output_file.csv]
    - Skips estimate and fetches data directly
    
API Key Options (in order of precedence):
  1. Environment variable: YOUTUBE_API_KEY or YT_API_KEY
  2. Secure prompt (hidden input)
    
Finding YouTube Channel IDs:
  - Channel ID format: starts with UC followed by 22 characters (e.g., UCBa659QWEk1AI4Tg7ZufK)
  - If you have @username, use: https://www.streamweasels.com/tools/youtube-channel-id-and-user-id-convertor/
  - Or check the channel URL for /channel/UC... in the address bar
    
Examples:
  export YOUTUBE_API_KEY="your_key_here"
  node fetchYouTubeData.js estimate UCBa659QWEk1AI4Tg7ZufK
  
  node fetchYouTubeData.js fetch UCBa659QWEk1AI4Tg7ZufK channel_data.csv
        `);
        process.exit(0);
    }
    
    const channelId = args[1];
    const outputFile = args[2] || 'youtube_data.csv';
    
    if (!channelId) {
        console.log('Error: Channel ID is required');
        console.log('Run with --help for usage information');
        process.exit(1);
    }
    
    async function getApiKey() {
        let apiKey = getApiKeyFromEnv();
        
        if (!apiKey) {
            console.log('No API key found in environment variables.');
            apiKey = await promptForApiKey();
        }
        
        if (!apiKey) {
            console.log('Error: API key is required');
            process.exit(1);
        }
        
        return apiKey;
    }
    
    async function runCommand() {
        const apiKey = await getApiKey();
    
        switch (command) {
            case 'estimate':
                const estimate = await getYouTubeChannelEstimate(apiKey, channelId);
                console.log('\n=== CHANNEL ESTIMATE ===');
                console.log(`Videos: ${estimate.videoCount.toLocaleString()}`);
                console.log(`Subscribers: ${estimate.subscriberCount.toLocaleString()}`);
                console.log(`Total Views: ${estimate.totalViews.toLocaleString()}`);
                console.log(`\n=== API USAGE ESTIMATE ===`);
                console.log(`API Calls: ${estimate.apiCalls}`);
                console.log(`Quota Units: ${estimate.quotaUnits}`);
                console.log(`Estimated Time: ~${estimate.estimatedTimeSeconds} seconds`);
                console.log('========================\n');
                break;
                
            case 'fetch':
                const data = await fetchYouTubeChannelData(apiKey, channelId, outputFile, true);
                console.log(`Successfully fetched data for ${data.length} videos`);
                break;
                
            case 'fetch-direct':
                const directData = await fetchYouTubeChannelData(apiKey, channelId, outputFile, false);
                console.log(`Successfully fetched data for ${directData.length} videos`);
                break;
                
            default:
                console.log(`Unknown command: ${command}`);
                console.log('Run with --help for usage information');
                process.exit(1);
        }
    }
    
    runCommand().catch(error => {
        console.error('Error:', error.message);
        process.exit(1);
    });
}