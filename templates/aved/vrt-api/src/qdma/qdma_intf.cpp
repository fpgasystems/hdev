#include "qdma/qdma_intf.hpp"
#include <iostream>

namespace vrt {
	QdmaIntf* QdmaIntf::instance = nullptr;
	uint8_t QdmaIntf::queueIdx = 0;
	bool QdmaIntf::queueExists = false;

	QdmaIntf::QdmaIntf(const std::string& bdf) {
		this->bdf = bdf;
		if (!queueExists) {
			queueExists = true;
			char* bus = strip(bdf.c_str());

			char formattedQueueName[256];
			sprintf(formattedQueueName, QDMA_DEFAULT_QUEUE, bus);
			queueName = std::string(formattedQueueName);
			std::cout << queueName << "\n";
			free(bus);
		}
	}

	QdmaIntf::QdmaIntf() {
		this->bdf = "c4:00.0";
		//create_qdma_queue(bdf.c_str());
	}

	QdmaIntf& QdmaIntf::getInstance(const std::string& bdf) {
		if (instance == nullptr) {
			instance = new QdmaIntf(bdf);
		}
		return *instance;
	}

	QdmaIntf& QdmaIntf::getInstance() {
		if(instance == nullptr) {
			instance = new QdmaIntf();
		}
		return *instance;
	}

	QdmaIntf::~QdmaIntf() {
		//delete_qdma_queue(bdf.c_str());
	}

	char* QdmaIntf::strip(const char* bdf) {
		char* output = (char*) malloc(3 * sizeof(char));
		if(sscanf(bdf, "%2[^:]", output) == 1) {
			output[2] = '\0';
		}
		return output;
	}

	char* QdmaIntf::create_qdma_queue(const char* bdf) {
		char* id = strip(bdf);
		// char qmax_string[256];
		// sprintf(qmax_string, QMAX_PATH, id);
		// int qmax_fd = open(qmax_string, O_WRONLY);
		// if(qmax_fd < 0) {
		//     fprintf(stderr, "Could not open qmax file.\n");
		// } else {
		//     ssize_t bytes = write(qmax_fd, "100", 3);
		//     if(bytes == -1) {
		//         fprintf(stderr, "Could not write to qmax file.\n");
		//         close(qmax_fd);
		//     }
		// }
		// create qdma queue
		char qdma_queue_name[12];
		sprintf(qdma_queue_name, QDMA_QUEUE_NAME, id);
		char cmd_add[256];
		sprintf(cmd_add, "dma-ctl %s q add idx 0 mode mm dir bi > /dev/null", qdma_queue_name);
		system(cmd_add);
		usleep(1000);
		char cmd_start[256];
		sprintf(cmd_start, "dma-ctl %s q start idx 0 idx_ringsz 15 dir bi > /dev/null", qdma_queue_name);
		system(cmd_start);
		usleep(1000);
		char* output = (char*) malloc(256 * sizeof(char));
		sprintf(output, QDMA_DEFAULT_QUEUE, id);
		free(id);
		return output;
	}

	int QdmaIntf::delete_qdma_queue(const char* bdf) {
		usleep(100000);
		char* id = strip(bdf);
		char cmd_stop[256];
		char qdma_queue_name[12];
		sprintf(qdma_queue_name, QDMA_QUEUE_NAME, id);
		sprintf(cmd_stop, "dma-ctl %s q stop idx 0 dir bi > /dev/null", qdma_queue_name);
		system(cmd_stop);
		usleep(1000);
		char cmd_del[256];
		sprintf(cmd_del, "dma-ctl %s q del idx 0 dir bi > /dev/null", qdma_queue_name);
		system(cmd_del);
		usleep(1000);
		free(id);
		return EXIT_SUCCESS;
	}


	ssize_t QdmaIntf::write_from_buffer(const char *fname, char *buffer, uint64_t size,
				uint64_t base)
	{
		int fd = open(queueName.c_str(), O_WRONLY);
		ssize_t rc;
		uint64_t count = 0;
		char *buf = buffer;
		off_t offset = base;

		do { /* Support zero byte transfer */
			uint64_t bytes = size - count;

			if (bytes > RW_MAX_SIZE)
				bytes = RW_MAX_SIZE;

			if (offset) {
				rc = lseek(fd, offset, SEEK_SET);
				if (rc < 0) {
					fprintf(stderr,
						"%s, seek off 0x%lx failed %zd.\n",
						fname, offset, rc);
					perror("seek file");
					return -EIO;
				}
				if (rc != offset) {
					fprintf(stderr,
						"%s, seek off 0x%lx != 0x%lx.\n",
						fname, rc, offset);
					return -EIO;
				}
			}

			/* write data to file from memory buffer */
			rc = write(fd, buf, bytes);
			if (rc < 0) {
				fprintf(stderr, "%s, W off 0x%lx, 0x%lx failed %zd.\n",
					fname, offset, bytes, rc);
				perror("write file");
				return -EIO;
			}
			if (rc != bytes) {
				fprintf(stderr, "%s, W off 0x%lx, 0x%lx != 0x%lx.\n",
					fname, offset, rc, bytes);
				return -EIO;
			}

			count += bytes;
			buf += bytes;
			offset += bytes;
		} while (count < size);

		if (count != size) {
			fprintf(stderr, "%s, R failed 0x%lx != 0x%lx.\n",
					fname, count, size);
			return -EIO;
		}
		close(fd);
		return count;
	}

	ssize_t QdmaIntf::read_to_buffer(const char *fname, char *buffer, uint64_t size,
				uint64_t base)
	{
		int fd = open(queueName.c_str(), O_RDONLY);
		ssize_t rc;
		uint64_t count = 0;
		char *buf = buffer;
		off_t offset = base;

		do { /* Support zero byte transfer */
			uint64_t bytes = size - count;

			if (bytes > RW_MAX_SIZE)
				bytes = RW_MAX_SIZE;

			if (offset) {
				rc = lseek(fd, offset, SEEK_SET);
				if (rc < 0) {
					fprintf(stderr,
						"%s, seek off 0x%lx failed %zd.\n",
						fname, offset, rc);
					perror("seek file");
					return -EIO;
				}
				if (rc != offset) {
					fprintf(stderr,
						"%s, seek off 0x%lx != 0x%lx.\n",
						fname, rc, offset);
					return -EIO;
				}
			}

			/* read data from file into memory buffer */
			rc = read(fd, buf, bytes);
			if (rc < 0) {
				fprintf(stderr,
					"%s, read off 0x%lx + 0x%lx failed %zd.\n",
					fname, offset, bytes, rc);
				perror("read file");
				return -EIO;
			}
			if (rc != bytes) {
				fprintf(stderr,
					"%s, R off 0x%lx, 0x%lx != 0x%lx.\n",
					fname, count, rc, bytes);
				return -EIO;
			}

			count += bytes;
			buf += bytes;
			offset += bytes;
		} while (count < size);

		if (count != size) {
			fprintf(stderr, "%s, R failed 0x%lx != 0x%lx.\n",
					fname, count, size);
			return -EIO;
		}
		close(fd);
		return count;
	}

	void QdmaIntf::write_buff(char* buffer, uint64_t start_addr, uint64_t size) {
		write_from_buffer(queueName.c_str(), buffer, size, start_addr);
	}

	void QdmaIntf::read_buff(char* buffer, uint64_t start_addr, uint64_t size) {
		read_to_buffer(queueName.c_str(), buffer, size, start_addr);
	}

} // namespace vrt
